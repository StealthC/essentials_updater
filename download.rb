require 'net/http'
require 'uri'

class Download
  attr_accessor :link, :filename, :folder
  def initialize(link, folder, filename)
    @link = link
    @folder = folder
    @filename = filename
  end
  def download
    #Verifica se o arquivo já existe
    #Verifica se a versão que queremos baixar é igual a que já temos
    puts @link
    uri = URI.parse(@link)
    FileUtils.mkdir_p(@folder) unless File.exists?(@folder)
    Net::HTTP.start(uri.host) do |http|
      response = http.request_head(@link)
      size = response['content-length'].to_i
      #verifica se o arquivo já existe
      pathfile = File.join(@folder, @filename)
      localsize = File.size?(pathfile)
      unless size == localsize
        if localsize.nil?
          puts "O arquivo ainda não foi baixado"
        else
          puts "Foi encontrado uma versão mais nova do arquivo"
          File.delete(pathfile)
        end
        open(pathfile, 'wb') do |file|
          file << open(@link).read
        end
      else
        puts "O arquivo já existe, e é esse mesmo"
      end
    end
  end
end

require 'nokogiri'
require 'open-uri'
doc = Nokogiri::HTML(open('http://www.bleepingcomputer.com/download/rkill/dl/10/'))
link = doc.css("div.dl_content p a").first['href']
rkill = Download.new(link, "rkill", "rkill.exe")
puts rkill.inspect
rkill.download
