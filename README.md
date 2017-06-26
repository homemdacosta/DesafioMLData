# Desafio Magazine Luiza
Desafio para consumir dados de duas fonte e disponibilizar os dados para consumo.

## Tecnologias utilizadas
O processo utiliza as seguintes tecnoclogias:
* MySQL - para persistência de dados
* Java - para ETL e dispobibilização de dados
* .NET - para consumo de dados do Kinesis stream

# Prerequisitos:
Softwares necessários para execução dos passos:
* Java 7
* MySQL
* Download de todos os pacotes disponibilizados nesse repositório. :)

# Deploy e Execução
As instruções a seguir o guiarão, passo a passo, no deploy e configuração do ambiente local.

## Criar schema no MySQL
   1. Antes de tudo, em um banco MySQL, execute o script de criação `"Create Schema MySQL.sql"`
      * Ao executá-lo o usuário `integration/integration` será criado para suprir o processo de ETL.

## Executando o ETL para extração de dados do MySQL fonte:
> O processo de ETL, precisa que o usuário integration exista no banco (conforme criado pelo script de criação do schema)
   1. Unzip `"ETL_package.zip"`
   2. Execute os seguintes arquivos:
      * `"Job Designs\ETL_Full\ETL_Full_run.bat"` - Populará as tabelas dimensão
      * `"Job Designs\FactTables\FactTables_run.bat"` - Populará as tabelas fato

## Consumir Kinesis stream:
O cosumidor, ao ser executado, consumirá o stream, enquanto estiver rodando, armazenando o que captura em um arquivo (por padrão `c:\raw-data\storage.txt`). Esse arquivo será consumido, posteriormente, por um processador que persistirá seu contúdo no banco MySQL.

   1. Unzip o arquivo ```"AmazonKinesisConsumer.zip"```
   * Se necessário, ajustar arquivos de conexão com banco e stream:
      * Editar o arquivo AmazonKinesisConsumer\App.config para configurar:
        * Nome do Kinesis Stream
            ```xml <add key="KinesisStreamName" value="big-data-analytics-desafio"/>```
        * Arquivo texto para ser processado pela aplicação Java (o diretório e o arquivo, em branco, devem ser criados):
            ```xml <add key="FilePath"  value="c:\\raw-data\\storage.txt"/> ```
   2.  Para consumir o stream, execute ```AmazonKinesisConsumer\bin\Debug\AmazonKinesisConsumer.exe```
         * Este processo não terá fim até que o usuário feche a janela de consumo.

## Persistindo o Kinesis stream no MySQL
   1. Unzip o arquivo ```"MailToDB.zip"```
   2. Execute o JAR "KTB-0.0.1-SNAPSHOT.jar" via prompt de comando ```java -jar KTB-0.0.1-SNAPSHOT.jar```
      * Se necessário, ajuste no arquivo "config\app.properties" as configurações de conexão ao banco e o caminho para o arquivo gerado pelo consumo do Kinesis (Por padrão, está configurado como: c:\\raw-data\\storage.txt).
   > Ao ver a mensagem ```"End of xxxxxxx processing..."``` feche a janela do prompt

## Expondo os dados via JSON
   1. Unzip o arquivo ```"AnalysisRest.zip"```
   2. Execute o JAR "ML-0.0.1-SNAPSHOT.jar" via prompt de comando: ```java -jar ML-0.0.1-SNAPSHOT.jar```
      * Se necessário, ajuste no arquivo ```config\app.properties``` as configurações de conexão ao banco.
   3. Para acessar a aplicação, abra o navegador e digite ```localhost:8080```. Ao ver a mensagem "XXXXXX" significa que a aplicação rest está funcionando.

# Utilização
Para consumir os arquivos há duas opções:
   1. Conectar-se no banco de dados e executar queries SQL diretamente na database.
   2. Utilizar a API disponibilizada para consumir as respostas json
      * Seguem os mapeamentos de cada um dos mapeamentos criados e suas explicações:
      | Mapeamento        | Are           | Cool  |
      | ------------- |:-------------:| -----:| 
      TODO

# Documentação do ETL
##TODO

# Autor
Rodrigo Homem da Costa
