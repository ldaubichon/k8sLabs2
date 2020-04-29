## Déploiement d'un front avec certificat ssl lets encrypt

**ATTENTION: Pensez à toujours définir le namespace lorsque vous déployez un objet**

**Ingress & Ingress Controller**
[https://kubernetes.io/docs/concepts/services-networking/ingress-controllers/](https://kubernetes.io/docs/concepts/services-networking/ingress-controllers/)

Un *ingress* permet de rendre les services accessibles depuis l'extérieur,et de répartir le traffic selon les host que vous avez défini.

Nous n'allons pas exposer de port particulier, pour cela il faudrait utiliser un service de type *NodePort*.

Pour pouvoir faire fonctionner vos *ingress*, vous allez avoir besoin d'un *ingress controller*.
Si vous créez simplement un ingress seul, il n'aura aucun effet.

***Installation***

Prérequis: Installation de Helm sur vos machines. 
> https://helm.sh/docs/intro/install/

Installation d'un ingress controller
>[https://www.nginx.com/products/nginx/kubernetes-ingress-controller/](https://www.nginx.com/products/nginx/kubernetes-ingress-controller/)

**Etape 1: créer un ingress controller.** 

Dans un premier temps vous devez installer le repository via une commande helm repo add:

    helm repo add stable https://kubernetes-charts.storage.googleapis.com/

Vous venez de charger les repository officiels de helm.

L'installation de helm est faite, vous pouvez vous rendre sur github pour installer votre *ingress controller* via un helm chart stable.

Récupérez le fichier de value.yaml afin de le personnaliser si vous le souhaitez, ce fichier est dans le repository 
du helm chart.

Pour spécifier le fichier de value lors de votre installation utilisez l'option **-f** 

Pour rappel, ici vous venez d'installer un *ingress controller,* celui de *nginx*. 

Dans les values du helm chart, remarquez un **type=loadbalancer**:
> sur votre infrastructure Scaleway un load balancer est automatiquement provisionné.

Testez la présence votre ingress controller avec la commande suivante: 

    kubectl --namespace monnamespace get services -o wide nginx-ingress-controller-controller

**Etape2: Cert Manager**

Afin d'avoir de l'https, vous devez déployer cert manager sur votre cluster. 
Cert manager va fonctionner dans votre cluster sous forme de déploiements.
Une fois que *cert manager* est déployé, vous devrez également créer un ***issuer*** qui va représenter 
l'autorité de certification.

**Installation de Cert Manager**

> [https://cert-manager.io/docs/installation/](https://cert-manager.io/docs/installation/)

Plusieurs modes d'installation sont présentés, réalisez cette installation via **Helm**.  

**Création d'un issuer**

La création d'un issuer va vous permettre de mettre en place une autorité de certification sur votre cluster.
Vous devrez donner votre email, pensez à bien utiliser ACME (voir documentation de cert manager). 
> [https://cert-manager.io/docs/concepts/issuer/](https://cert-manager.io/docs/concepts/issuer/)

Lorsque le déploiement est terminé, faite une commande kubectl pour voir l'état de toutes vos ressources Kubernetes dans votre namespace, essayez de vous référer à la documentation kubernetes pour obtenir la commande.

 

*Nous venons de déployer un **ingress controller**, **cert manager**, et un **issuer** qui va représenter
l'autorité de certification pour vos futurs certificats. 
Pour rappel votre **ingress controller** va vous permettre de déployer des "**ingress**" vers vos futurs 
services Kubernetes.*

**Hello Kubernetes**

Ici vous allez déployer une petite image hello-kubernetes, nous allons voir que le trafic va être load balancé entre nos différentes nodes du cluster à la fin du lab. 

**Etape 1: Deployment**

Créez un déploiement de 3 replicas, dans votre namespace. Celui-ci doit utiliser
l'image suivante: paulbouwer/hello-kubernetes:1.7

- Vérifiez que votre déploiement est bien dans votre namespace, vérifiez aussi que ce déploiement possède 
3 pods en status READY. 

Une fois que le déploiement est prêt, vous devez créer un service. 

> [https://kubernetes.io/docs/concepts/services-networking/service/](https://kubernetes.io/docs/concepts/services-networking/service/)

Votre service doit référencer votre déploiement et faire partie du même namespace.
Pensez à l'option ***selector***. Vous pouvez également faire un ***describe*** de votre déploiement pour vérifier 
ses caractéristiques.

Vérifier votre service via une commande kubectl, faites attention a ce qu'il soit dans le bon namespace.
Vous pouvez également voir son adresse ip et son type.  

    kubectl get svc -n monnamespace

Votre déploiement est fait, votre service est également déployé, maintenant vous devez déployer un 
ingress. Pour rappel l'***ingress controler*** utilisera cet ingress pour diriger le trafic vers votre service. 
> [https://kubernetes.io/docs/concepts/services-networking/ingress/](https://kubernetes.io/docs/concepts/services-networking/ingress/)

Pour cela utilisez ce nom dns: 

> prenom-hello.daubichon.com

, je m'occuperai de réaliser l'entrée DNS. 

Lorsque votre ingress est déployé, vous pouvez également le vérifier avec une commande kubectl:

    kubectl get ing -n votre namespace

Consultez votre site dans un navigateur.

Vous remarquerez que pour le moment vous n'avez pas de certificat SSL. 

Nous allons y remédier en générant un certificat associé au nom DNS qui vous est attribué dans ce lab. 
Pour cela vous devez générer un objet de type **certificate**.

>    [https://cert-manager.io/docs/usage/certificate/](https://cert-manager.io/docs/usage/certificate/)


Référez vous à la documentation de cert manager pour obtenir un exemple de yaml et appliquez le pour 
avoir votre certificat. Attention a bien associer au DNS utilisé certains champs du fichier yaml.

Vous devriez maintenant avoir un certificat SSL lets encrypt et votre front hello kubernetes en visuel !
Supprimez un pod ou deux et faites un refresh de la page web pour vérifier que le load balancer redirige le traffic entre les différents pods.
