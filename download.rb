require 'net/http'
require 'uri'
require 'progressbar'
require 'nokogiri'
require 'open-uri'

class FileDownload
  attr_accessor :link, :filename, :folder
  def initialize(link, folder, filename)
    @link = link
    @folder = folder
    @filename = filename
  end
  def download
    #Verifica se o arquivo já existe
    #Verifica se a versão que queremos baixar é igual a que já temos
    puts "Baixando #{@filename} para #{folder}"
    uri = URI.parse(@link)
    FileUtils.mkdir_p(@folder) unless File.exists?(@folder)
    size = 0
    #verifica se o arquivo já existe
    pathfile = File.join(@folder, @filename)
    localsize = File.size?(pathfile)
    Net::HTTP.start(uri.host) do |http|
      #tenta descobrir o tamanho do arquivo
      response = http.request_head(@link)
      size = response['content-length'].to_i
    end
    unless size == localsize
      if localsize.nil?
        puts "O arquivo ainda não foi baixado"
      else
        puts "Foi encontrado uma versão mais nova do arquivo"
        File.delete(pathfile)
      end
      open(@link) {|f|
        File.open(pathfile,"wb") do |file|
          file.puts f.read
        end
      }
    else
      puts "O arquivo já existe, e é esse mesmo"
    end
  end
end


class BleepingComputerDownload < FileDownload
  def initialize(baseurl, folder, filename)
    doc = Nokogiri::HTML(open(baseurl))
    @link = doc.css("div.dl_content p a").first['href']
    @folder = folder
    @filename = filename
  end
end
