## TP3 Déploiement d'un wordpress avec base de données MySQL

Ce TP fait intervenir ces différentes notions:

 - PersistentVolume
 - VolumeClaim
 - Secret

Le volume persistant va être automatiquement provisionné par scaleway lorsque vous allez déployer votre object kubernetes.

Les Volumes persistants sont indépendants du cycle de vie de vos pods.

Vous allez également aborder la notion de secrets pour stocker votre mot de passe
mysql. 

## Les Etapes 

> Générer un secret pour MySQL
> Créer un volume claim pour mysql
> Générer un déploiement pour votre MySQL
> Créer un service pour votre MySQL
> Générer un déploiement pour votre Wordpress
> Créer un volume claim pour votre Wordpress
> Créer un service pour votre Wordpress
> Appliquer un certificat SSL sur votre Wordpress 

**Etape 1:**

Générer un secret:

Vous pouvez exporter votre commande sous forme de Yaml pour voir ce que la commande ci dessous
ajoute à votre secret.

Puis faire un `kubectl create -f secret.yaml`

Pour rappel:

    kubectl create secret generic password --from-literal=password=votremotdepasse -n votrenamespace --dry-run -o yaml


>Les secrets Kubernetes: https://kubernetes.io/docs/concepts/configuration/secret/

Consultez votre secret via une commande kubectl:

    kubectl get secrets -n lionel

![](images/mysqlwordpress/secretmysql.png)

Vous pouvez aussi faire un describe sur votre secret, vous pouvez également créer votre secret à la main,
en revanche cela implique d'encoder le secret en base64 avant. 


**Etape 2:** 

Créer un premier volume ***Persistent Volume Claim***

> https://kubernetes.io/docs/concepts/storage/persistent-volumes/#persistentvolumeclaims

Lors de la création de votre volume, utilisez les paramètres suivants:

* créez le label suivant [app: wordpress]
* Donnez ce nom à votre [Pvolumeclaim name: mysql]
* Donnez un Storage de 20Gi
* Donnez la valeur ReadWriteOnce au paramètre [accessModes: ]

![](images/mysqlwordpress/pvcmysql.png)

Cette étape va automatiquement provisionner un volume sur ScaleWay

**Etape 3:**

Créer un déploiement MySQL sans réplica. 

    kubectl create deployment wordpress-mysql --image=mysql:5.6 --dry-run -o yaml > wordpress-mysqldeployment.yaml

Votre déploiement n'est pas complet mais vous devriez obtenir un .yaml sensiblement identique:

![](images/mysqlwordpress/deploymentmysql.png)

Dans votre déploiement vous allez avoir besoin de référencer plusieurs éléments:

**1 - Votre secret, créé en étape 1**

**2 - Votre volume claim associé à votre déploiement** 

Ces deux notions se passent au niveau des ***specs*** de votre déploiement. 

Lorsque vous aurez édité votre .**yaml** vous devriez obtenir un résultat similaire à celui-ci:

![](images/mysqlwordpress/deploymentfull.png)

Faites votre déploiement.

Explication:

 - Dans les specs du container, le paramètre env: va vous permettre d'exporter une valeur depuis votre secret mysql-pass, donc la clé   définissant le mot de passe est "password"

 - Au niveau du container, le parametre volumeMounts permet de définir le volume utilisé (votre volumeclaim) et le path souhaité.

 - Le paramètre volumes va définir quel volumle claim vous allez utiliser. C'est le claimName qui va associer votre volume au pod.

Vous avez désormais un volume, un déploiement et un secret pour votre mysql. 
Vous pouvez vérifier via les commandes kubectl. 

**Etape 4:**

Le service

Créez un service kubernetes qui puisse exposer votre déploiement.

> Pensez à utiliser "selector" et garder le bon label. 

Votre mysql est maintenant déployé dans votre namespace. 
Vous devriez obtenir un résultat similaire:

![](images/mysqlwordpress/servicemysql.png)


## Wordpress
