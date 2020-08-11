# demo-kubevirt

Esse repositório contém os artefatos usados na demonstração da apresentação **Virtualização no Kubernetes com KubeVirt** durante o [[Online] Cloud Native São Paulo - Meetup #16](https://www.meetup.com/Cloud-Native-Sao-Paulo/events/272334689/).

## Ambiente

Para conseguir executar o roteiro, você precisa de um ambiente de demonstração funcional. As instruções de como construir um estão disponíveis [aqui](lab-setup/README.md).

## Roteiro

1) Vamos validar quais os recursos que o KubeVirt e o CDI disponibilizaram no nosso ambiente:

```bash
kubectl api-resources | grep kubevirt.io
```

2) Vamos criar uma primeira `VirtualMachine` a partir de uma imagem de Cirrus disponível em um registry (o mesmo usado pelos containers).

```bash
less vm-cirrus.yml

kubectl apply -f vm-cirrus.yml
```

3) Depois da dua criação, vemos que a `VirtualMachine` ainda não tem uma `VirtualMachineInstance` criada. Isso se dá porque não definimos o `spec.running` como `true`.

```bash
kubectl get vm,vmi
```

4) Podemos modificar esse campo da mesma forma que fazemos com outros recursos do Kubernetes. E vemos que o KubeVirt já começa a criar nossa instância:

```bash
kubectl patch virtualmachine cirrus-vm-1 --type merge -p '{"spec":{"running":true}'

kubectl get vm,vmi
```

5) A CLI do KubeVirt nos fornece facilidades como, por exemplo, acesso a console (serial):

```bash
kubectl virt console cirrus-vm-1
```

6) Ou um "atalho" para manipular o campo `spec.running`:

```bash
kubectl virt stop cirrus-vm-1

kubectl get vm,vmi
```

7) Outro componente importante é o Containerized Data Importer (CDI), que fornece o recurso de `DataVolume` e permite importar discos KVM de forma automática (qcow2, raw, etc) para serem usados com o KubeVirt. Ele fornece automação e abstração em relação aos `PersistentVolumeClaim`.

```bash
less cdi-dv-fedora.yml

kubectl apply -f cdi-dv-fedora.yml
```

8) Esse processo pode ser acompanhado usando via logs ou CLI:

```bash
watch kubectl get dv,pvc
```

9) Vamos criar uma outra `VirtualMachine` usando o `DataVolume` 

```bash
less vm-fedora.yml

kubectl apply -f vm-fedora.yml
```

10) Esse processo vai disparar uma automação de clonagem do `DataVolume` que importamos anteriormente, antes da execução propriamente dita da `VirtualMachineInstance`:

```bash
watch kubectl get dv

kubectl get vm,vmi,dv,pvc
```

11) Além de acesso a console serial, também podemos acessar a console gráfica (VNC) via CLI do KubeVirt (virtctl):

```bash
kubectl virt vnc fedora-vm-1
```

12) Dado que a nossa máquina é baseada em um disco persistente, podemos reinicia-la (re-scheduling) sem perda de dados:

```bash
kubectl virt restart fedora-vm-1
```

13) Outra facilidade via CLI do KubeVirt (virtctl) é a exposição de serviços:

```bash
kubectl virt expose vmi fedora-vm-1 --name=fedora-vm-ssh --port=22 --type=NodePort

kubectl get svc fedora-vm-ssh

kubectl get nodes -o wide

ssh fedora@<ip do node> -p <porta do svc>
```

14) Importar imagens de repositórios externos é importante, mas de vez em sempre precisamos usar imagens que temos localmente. A CLI do KubeVirt (virtctl) em conjunto com o CDI nos permite essa facilidade:

```bash
kubectl port-forward -n cdi service/cdi-uploadproxy 18443:443

kubectl virt image-upload dv fedora-cloud-base-31 \
            --namespace default \
            --size=5Gi \
            --image-path lab-setup/images/Fedora-Cloud-Base-31-1.9.x86_64.raw.xz \
            --uploadproxy-url https://localhost:18443 \
            --insecure

kubectl get dv,pvc
```

15) Se quiser explorar, não esqueça de apagar os recursos para abrir espaço para novas aventuras!

```bash
kubectl delete vm cirrus-vm-1 fedora-vm-1

kubectl delete dv fedora-cloud-base-{31,32}
```
