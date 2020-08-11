# Preparação do Ambiente

Esses são os passos para preparar o ambiente de demonstração. Todos os comandos assumem que você está dentro do diretório `lab-setup/`, em uma máquina Linux com Docker Engine e Kind devidamente instalados.

0) Validar se a sua máquina possui capacidade de virtualização assistida aninhada:

```bash
cat /sys/module/kvm_intel/parameters/nested
```

1) Subir o repositório de imagens local:

```bash
./local-repo.sh
```

2) Criar um cluster K8S local com Kind:

```bash
kind create cluster --config kind-config.yml
```

3) Instalar o operator do KubeVirt e criar o seu recurso customizado (versão mais nova):

```bash
export KUBEVIRT_VERSION=$(curl -s https://api.github.com/repos/kubevirt/kubevirt/releases | grep tag_name | grep -v -- - | sort -V | tail -1 | awk -F':' '{print $2}' | sed 's/,//' | xargs)
```

```bash
kubectl create -f https://github.com/kubevirt/kubevirt/releases/download/${KUBEVIRT_VERSION}/kubevirt-operator.yaml
```

```bash
kubectl create -f https://github.com/kubevirt/kubevirt/releases/download/${KUBEVIRT_VERSION}/kubevirt-cr.yaml
```

4) Instalar o operator do CDI e criar o seu recurso customizado (versão mais nova):

```bash
export CDI_VERSION=$(curl -s https://github.com/kubevirt/containerized-data-importer/releases/latest | grep -o "v[0-9]\.[0-9]*\.[0-9]*")
```

```bash
kubectl create -f https://github.com/kubevirt/containerized-data-importer/releases/download/$CDI_VERSION/cdi-operator.yaml
```

```bash
kubectl create -f https://github.com/kubevirt/containerized-data-importer/releases/download/$CDI_VERSION/cdi-cr.yaml
```

5) Habilitar feature-gates do KubeVirt:

```bash
kubectl apply -f kubevirt-config.yml
```

6) Instalar o CLI do KubeVirt:

```bash
curl -L -o virtctl \
    https://github.com/kubevirt/kubevirt/releases/download/${KUBEVIRT_VERSION}/virtctl-${KUBEVIRT_VERSION}-linux-amd64
chmod +x virtctl
```

ou

```bash
kubectl krew install virt
```
