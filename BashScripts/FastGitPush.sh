#!/bin/bash

echo "Digite o path do repositório com o .git:"
echo "[Path padrão: $(pwd)]"
read -r RepositoryPath

if [ -z "$RepositoryPath" ]; then
    RepositoryPath=$(pwd)
fi

if [ -d "$RepositoryPath/.git" ]; then
    if [ -r "$RepositoryPath" ]; then
        cd "$RepositoryPath" || exit 1
    else
        echo "Erro: Não temos permissão de leitura para o diretório fornecido."
        exit 1
    fi
else
    echo "Erro: O path não existe ou não contém um diretório .git."
    exit 1
fi

data_atual=$(date +"%Y-%m-%d")
echo "Digite o nome do commit: [Padrão: 'Commit: $data_atual']"
read -r Message

if [ -z "$Message" ]; then
    Message="Commit: $data_atual"
fi

if command -v git >/dev/null; then
    git pull origin main
    git add .
    git commit -am "$Message"
    git push origin main
    git status
else
    echo "Erro: Git não encontrado. Por favor, instale o git."
    exit 1
fi
