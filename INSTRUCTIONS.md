# Instruções

Esse é um boilerplate para utilização e criação de novos projetos em Phoenix Framework.

Para facilitar o início de novos projetos, esse repositório já contêm os arquivos Dockerfile e docker-compose.

### Duplicando esse repositório

Before you can push the original repository to your new copy, or mirror, of the repository, you must create the new repository on GitHub.com. In these examples, dhonysilva/fazenda.

No terminal, crie um `bare clone` desse repositório.

```
git clone --bare https://github.com/dhonysilva/phxboilerplate.git
```

Mirror-push to the new repository.

```
cd phxboilerplate.git
git push --mirror git@github.com:dhonysilva/fazenda.git
```

Remove the temporary local repository you created earlier.
```
$ cd ..
$ rm -rf phxboilerplate.git
```

Para mais informações, consulte essa [`documentação`](https://docs.github.com/en/repositories/creating-and-managing-repositories/duplicating-a-repository). 

### Comandos no docker-compose


#### Nova aplicação

```
docker-compose run --rm phoenix mix phx.new . --app <nome da aplicação> --binary-id
```
O `--binary-id` altera a aplicação para gerar a chave primária com o formato UUID4 ao invés do padrão id to tipo inteiro.

Uma mensagem de `Fetch and install dependencies` aparecerá. Selecione Yes.

Essa etapa levará um certo tempo.

```
running mix deps.get
running mix assets.setup
running mix deps.compile
```


Após gerar a aplicação, realize a seguinte alteração.

Acesse o arquivo da pasta `/scr/config/devs.exs`
Altere o nome que está na propriedade `hostname` de `localhost` para `db`.

```
# Configure your database
config :fazenda, Fazenda.Repo,
  username: "postgres",
  password: "postgres",
  hostname: "db",
  database: "fazenda_dev",
  stacktrace: true,
  show_sensitive_data_on_connection_error: true,
  pool_size: 10
```

`db` é o nome do service de banco de dados definido no `docker-compose`.

#### Novo banco de dados

```
docker-compose run --rm phoenix mix ecto.create
```

O banco de dados Fazenda.Repo será criado.

### Alterar o endereço de IP localhost

No arquivo `src/config/dev.exs`, altere

```
http: [ip: {127, 0, 0, 1}, port: 4000],
```

Para

```
http: [ip: {0, 0, 0, 0}, port: 4000],
```

#### Rodando a aplicação

Execute

```
docker-compose up
```

Now we can visit [`localhost:4000`](http://localhost:4000) from our browser.

Liste todos os conteineres em operação.
```
docker ps
````

Copie o Id do container dbt.

Execute o comando abaixo para acessar o conteiner.
```
docker exec -it <container-id> /bin/bash
````

Criar o Accounts User

```
docker-compose run --rm phoenix mix phx.gen.live Accounts User users name:string age:integer
```
Uma outra alternativa é criar o `phx.gen.auth`.
