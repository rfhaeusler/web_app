# -*- coding: utf-8 -*-
require "sinatra"
require "tempfile"


enable :sessions

get '/' do

  i= 0
  line = []
  content = []
  while(i<4) do
    line[i] = File.open("public/tutorial#{i+1}.txt", "r").readlines
    content[i] = line[i].join
    i +=1  
  end
  erb :upload, :locals => {:tutorial1 => content[0],:tutorial2 => content[1], :tutorial3 => content[2], :tutorial4 => content[3]}
end

post '/upload' do
  
  name =  params['fileup'][:filename] 
  name[".xml"] = ""
  f = Tempfile.new([name, ".xml"])          #cria arquivo com parte do nome em /tmp/ (cria sempre um nome unico).
  f.write(params['fileup'][:tempfile].read) #passa o conteudo do arquivo 'fileup' para o arquivo criado.
  #f.path é o endereço do arquivo.
  session[:name] = params['fileup'][:filename]
  
  if system(" xmllint --dtdvalid LMPLCurriculo.DTD --noout #{f.path}" )
    %x[xsltproc lattes2mods.xsl #{f.path} >  #{f.path}.mods]
    %x[xml2bib -b -w  #{f.path}.mods >  #{f.path}.bib]  
    index = f.path
    index[index.length] = ".bib"
    session[:index] = index
    lines = File.open(session[:index], "r").readlines
    content = lines.join
    "<result>#{content}</result>"
  else
    "ERROR"
  end
  
end

get '/convert' do 
  
  
  name = session[:name]
  
  name[name.length] = ".bib"
  
  send_file session[:index], :filename => "#{name}"   #cria uma opção de download do arquivo gerado na converção
  #para o cliente.
end


