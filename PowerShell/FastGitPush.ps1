<#
.SYNOPSIS
    Este script automatiza o processo de commit e push de alterações para um repositório Git.

.DESCRIPTION
    O script realiza as seguintes ações:
    1. Solicita o caminho do repositório com .git.
    2. Verifica se o caminho fornecido contém um diretório .git.
    3. Move para o diretório do repositório.
    4. Obtém a data atual.
    5. Solicita o nome do commit (opcional).
    6. Executa git pull, git add, git commit, git push e git status.
    7. Verifica se o Git está instalado.

.NOTES
    Nome do Script: FastGitPush.ps1
    Autor: GuilhermeLBonomo
    Data: 2023-12-01

.EXAMPLE
    .\FastGitPush.ps1
#>

$RepositoryPath = Read-Host "Digite o caminho do repositório com .git (Padrão: $(Get-Location))"

if (-not $RepositoryPath) {
    $RepositoryPath = Get-Location
}

if (Test-Path "$RepositoryPath\.git" -and (Test-Path -Path $RepositoryPath -PathType Container)) {
    try {
        Set-Location -Path $RepositoryPath -ErrorAction Stop
    } catch {
        Write-Host "Erro: Não temos permissão de leitura para o diretório fornecido."
        exit 1
    }
} else {
    Write-Host "Erro: O caminho não existe ou não contém um diretório .git."
    exit 1
}

$data_atual = Get-Date -Format "yyyy-MM-dd"
Write-Host "Digite o nome do commit (Padrão: 'Commit: $data_atual')"
$Message = Read-Host

if (-not $Message) {
    $Message = "Commit: $data_atual"
}

if (Test-Path (Get-Command git -ErrorAction SilentlyContinue)) {
    git status
    git pull origin main
    git add .
    git status
    git commit -am $Message
    git push origin main
    git status
} else {
    Write-Host "Erro: Git não encontrado. Por favor, instale o git."
    exit 1
}