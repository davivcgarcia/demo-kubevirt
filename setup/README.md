# Demonstração - Preparo do Ambiente

## Sobre

Espera-se que os seguintes componentes já estejam devidamente instalados e configurados na máquina de demonstração:

- [Docker Engine CE v19.03.12+](https://docs.docker.com/get-docker/)
- [Kind v0.8.1+](https://kind.sigs.k8s.io/docs/user/quick-start/)
- [Kubernetes CLI (kubectl) v1.18+](https://kubernetes.io/docs/tasks/tools/install-kubectl/)
- [Kubernetes Krew v0.3.4+](https://krew.sigs.k8s.io/docs/user-guide/setup/install/)

Na apresentação usei um Lenovo Thinkpad X1 Carbon, rodando Fedora Workstation 32, mas a demonstração funciona bem com máquinas com:

- **SO:** Ubuntu/Fedora/Debian/CentOS/RHEL
- **CPU:** 2Ghz+ c/ 2 cores
- **RAM:** 8GB
- **HDD:** 20GB livres.

## Roteiro de Preparo

**0)** Tenha certeza que está no diretório correto:

```bash
git clone https://github.com/davivcgarcia/demo-kubevirt.git

cd demo-kubevirt/setup
```

**1)** Validar se a sua máquina possui capacidade de virtualização assistida aninhada:

```bash
cat /sys/module/kvm_intel/parameters/nested
```

**2)** Baixe as imagens do Fedora necessárias para as atividades:

```bash
mkdir images

cd images

curl -LO http://fedora.c3sl.ufpr.br/linux/releases/31/Cloud/x86_64/images/Fedora-Cloud-Base-31-1.9.x86_64.raw.xz

curl -LO http://fedora.c3sl.ufpr.br/linux/releases/32/Cloud/x86_64/images/Fedora-Cloud-Base-32-1.6.x86_64.raw.xz
```

**3)** Retorne ao diretório anterior e execute o script para subir o repositório local de imagens:

```bash
cd ..

./local-repo.sh
```

**4)** Criar um cluster Kubernetes local com Kind com 1 control-plane e 1 worker node:

```bash
kind create cluster --config kind-config.yml
```

**5)** Instalar o operator do KubeVirt (versão mais nova) e criar o seu recurso customizado para instalação:

```bash
export KUBEVIRT_VERSION=$(curl -s https://api.github.com/repos/kubevirt/kubevirt/releases | grep tag_name | grep -v -- - | sort -V | tail -1 | awk -F':' '{print $2}' | sed 's/,//' | xargs)

kubectl create -f https://github.com/kubevirt/kubevirt/releases/download/${KUBEVIRT_VERSION}/kubevirt-operator.yaml

kubectl create -f https://github.com/kubevirt/kubevirt/releases/download/${KUBEVIRT_VERSION}/kubevirt-cr.yaml
```

**6)** Instalar o operator do CDI (versão mais nova) e criar o seu recurso customizado para instalação:

```bash
export CDI_VERSION=$(curl -s https://github.com/kubevirt/containerized-data-importer/releases/latest | grep -o "v[0-9]\.[0-9]*\.[0-9]*")

kubectl create -f https://github.com/kubevirt/containerized-data-importer/releases/download/$CDI_VERSION/cdi-operator.yaml

kubectl create -f https://github.com/kubevirt/containerized-data-importer/releases/download/$CDI_VERSION/cdi-cr.yaml
```

**7)** Habilitar feature-gates do KubeVirt:

```bash
kubectl apply -f kubevirt-config.yml
```

**8)** Instalar o CLI do KubeVirt via `krew`:

```bash
kubectl krew install virt
```
