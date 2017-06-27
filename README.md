# Desafio Magazine Luiza
Desafio para consumir dados de duas fontes e disponibilizar os dados para consumo.

## Tecnologias utilizadas
O processo utiliza as seguintes tecnologias:
* MySQL - para persistência de dados
* Java - para ETL e disponibilização de dados
* .NET - para consumo de dados do Kinesis stream

# Pré-requisitos:
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
> O processo de ETL, precisa que o usuário *integration exista no banco (conforme criado pelo script de criação do schema)
   1. Unzip `"ETL_package.zip"`
   2. Execute os seguintes arquivos:
      * `"Job Designs\ETL_Full\ETL_Full_run.bat"` - Fará o ETL das tabelas dimensão e staging
      * `"Job Designs\FactTables\FactTables_run.bat"` - Fará o ETL das tabelas fato

## Consumir Kinesis stream:
O consumidor, ao ser executado, consumirá o stream, enquanto estiver rodando, armazenando o que captura em um arquivo (por padrão `c:\raw-data\storage.txt`). Esse arquivo será consumido, posteriormente, por um processador que persistirá seu conteúdo no banco MySQL.

   1. Unzip o arquivo ```"AmazonKinesisConsumer.zip"```
   * Se necessário, ajustar arquivos de conexão com banco e stream:
      * Editar o arquivo AmazonKinesisConsumer\App.config para configurar:
        * Nome do Kinesis Stream:
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
      * Seguem os mapeamentos  criados e suas explicações:
      ```localhost:8080/brand``` -->  Lista todas as marcas da base.</br>
      ```localhost:8080/product``` -->  Lista todos os produtos.</br>
      ```localhost:8080/seller``` -->  Lista todos os vendedores.</br>
      ```localhost:8080/statecity``` -->  Lista todas as localizações (estado e cidade).</br>
      ```localhost:8080/Fact-Order-Qualitative``` -->  Lista todos os pedidos de maneira qualitado, ou seja, descreve os produtos que compõem o pedido. Referência à tabela fact_order_qualitative.</br>
      ```localhost:8080/Fact-Order-Qualitative/id/*{id}*``` -->  Lista todos os dados qualitativos sobre um order_id específico.</br>
      ```localhost:8080/Fact-Order-Quantitative/all``` -->  Lista todos os dados relativos aos pedidos, como frete e custo total. Referência à tabela fact_order_quantitative.</br>
      ```localhost:8080/Fact-Order-Quantitative/status?status=*<status>*``` -->  Lista todos os pedidos com o status igual ao informado.</br>
      ```localhost:8080/Fact-Order-Quantitative/sumByOrderDate``` -->  Lista informações agregadas, por dia, de soma total de frete e total dos pedidos.</br>
      ```localhost:8080/Fact-Order-Quantitative/sumByOrderDate/*{id}*``` -->  Lista informações agregadas, por dia, de soma total de frete e total de um determinado dia.</br>
      ```localhost:8080/Fact-Mail/``` -->  Lista todas os dados coletados do stream Kinesis.</br>
      ```localhost:8080/Fact-Mail/event/*{type}*``` -->  Lista todos os dados coletados do stream Kinesis para um determinado do tipo requerido.</br>

# Documentação do ETL
Para documentar o ETL de maneira simples, no documento ```ETL_mapping.txt``` encontrará a relação entre coluna do schema gerado para com a sua fonte de dados específica.

# Autor
Rodrigo Homem da Costa
