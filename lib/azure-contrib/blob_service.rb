# This code requires Ruby 2.0+ ... it's 2014, people

# Make sure the original is included
require 'azure/blob/blob_service'
require 'celluloid'
require 'timeout'
require 'stringio'

module ChunkHelper
  def each_chunk(chunk_size=2**20)
    yield read(chunk_size) until eof?
  end
end

class ::StringIO
  include ChunkHelper
end

class ::File
  include ChunkHelper
end


# The maximum size for a block blob is 200 GB, and a block blob can include no more than 50,000 blocks.
  # http://msdn.microsoft.com/en-us/library/azure/ee691964.aspx

class BlockActor
  include Celluloid

  def initialize(service, container, blob, options = {})
    @service, @container, @blob, @options = service, container, blob, options
  end

  def upload(block_id, chunk, retries = 0)
    logger = @options[:logger]

    Timeout::timeout(@options[:timeout] || 30){
      logger.debug "Uploading block #{block_id}"
      options = @options.dup
      options[:content_md5] = Base64.strict_encode64(Digest::MD5.digest(chunk))
      content_md5 = @service.create_blob_block(@container, @blob, block_id, chunk, options)
      logger.debug "Done uploading block #{block_id} #{content_md5}"
      [block_id, :uncommitted]
    }
  rescue Timeout::Error, Azure::Core::Error => e
    logger.debug "Failed to upload #{block_id}: #{e.class} #{e.message}"
    if retries < 5
      logger.debug "Retrying upload (#{retries})"
      upload(block_id, chunk, retries += 1)
    else
      logger.error "Complete failure to upload #{retries} retries"
    end
  end

end

module Azure
  class BlobService

    # def get_blob_with_chunking(container, blob, option)
    #
    # end
    #
    # alias_method :get_blob_without_chunking, :get_blob
    # alias_method :get_blob, :get_blob_with_chunking

    def create_block_blob_with_chunking(container, blob, content_or_filepath, options={})
      opt = options.dup
      chunking = opt.delete(:chunking)
      logger = opt.delete(:logger)
      if chunking
        block_list = upload_chunks(container, blob, content_or_filepath, options)

        unless block_list
          logger.error "EMPTY BLOCKLIST!"
          return false
        end

        logger.info("Done uploading, committing ...", blocks: block_list.size)
        logger.debug("Block list order", order: block_list.map{|x,y| x})
        logger.debug("Block list fixed", order: block_list.sort_by{|x,y| x}.map{|x,y| x})
        options[:blob_content_type] = options[:content_type]
        commit_blob_blocks(container, blob, block_list, opt)
        logger.info "Uploading done"
      else
        content = content_or_filepath
        create_block_blob_without_chunking(container, blob, content, opt)
      end
    end

    # The maximum size for a block blob is 200 GB, and a block blob can include no more than 50,000 blocks.
    # http://msdn.microsoft.com/en-us/library/azure/ee691964.aspx
    def upload_chunks(container, blob, content_or_filepath, options = {})
      counter = 1
      futures = []
      pool    = BlockActor.pool(size: 10, args: [self, container, blob, options])

      if (content_or_filepath =~ /\x00/)
        # contains null characters - has to be content, avoid File.file check that will fail
        classType = ::StringIO
      elsif File.file?(content_or_filepath)
        # filename
        classType = ::File
      else
        # string
        classType = ::StringIO
      end

      block_list = []
      classType.open(content_or_filepath) do |f|
        until f.eof?
          block_id = counter.to_s.rjust(5, '0')
          futures << pool.future.upload(block_id, f.read(2**20))
          counter += 1
          temp = []
          futures.each do |f|
            if f.ready?
              block_list << f.value
            else
              temp << f
            end
            # GC.start
          end
          futures = temp
        end
      end

      block_list += futures.map(&:value)
      pool.terminate
      futures = nil
      return block_list
    end

    alias_method :create_block_blob_without_chunking, :create_block_blob
    alias_method :create_block_blob, :create_block_blob_with_chunking

  end

end
