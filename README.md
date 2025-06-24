# 🚀 Bastion Clients - Terraform + AKS + Teleport

Infrastructure complète pour déployer :

- Un cluster **AKS** (Azure Kubernetes Service)
- Le service **Teleport** pour la gestion des accès SSH & RBAC
- Une **VM Ubuntu client**
- Une **VM Windows Active Directory (AD)**
- Le tout provisionné avec **Terraform** et géré avec **Makefile**

---

## 📁 Arborescence

```
bastion-clients/
├── terraform/                # Contient les fichiers Terraform pour le cluster AKS
│   └── clients/
│       ├── ubuntu/           # Déploiement VM Ubuntu
│       └── ad/               # Déploiement VM Windows AD
├── helm/                     # Fichier de configuration Helm pour Teleport
├── k8s/                      # Fichier YAML pour les agents Teleport
├── Makefile                  # Toutes les commandes automatisées
└── README.md                 # Ce fichier
```

---

## ✅ Prérequis

- `az` (Azure CLI) connecté (`az login`)
- `terraform` installé
- `helm` installé
- `kubectl` configuré

---

## 🚀 Commandes Makefile

### 🔧 Infrastructure principale

| Commande              | Description                                      |
|-----------------------|--------------------------------------------------|
| `make apply`          | Déploie le cluster AKS avec Terraform            |
| `make destroy`        | Supprime toute l'infra AKS                       |
| `make plan`           | Affiche le plan Terraform                        |
| `make kubeconfig`     | Récupère les credentials `kubectl` pour AKS      |

---

### 🚀 Teleport

| Commande              | Description                                      |
|-----------------------|--------------------------------------------------|
| `make teleport`       | Installe Teleport dans AKS via Helm              |
| `make teleportupdate` | Met à jour la release Teleport via Helm          |
| `make agents`         | Déploie les agents Teleport dans le cluster      |

> ⚠️ `make teleport` ajoute automatiquement un utilisateur `admin` avec les bons rôles (⚙️ tctl)

---

### 🖥️ Clients

| Commande                      | Description                                  |
|-------------------------------|----------------------------------------------|
| `make apply-ubuntu-client`    | Déploie une VM Ubuntu avec clé SSH           |
| `make destroy-ubuntu-client`  | Supprime la VM Ubuntu                        |
| `make apply-add-client`       | Déploie une VM Windows AD + IIS              |
| `make destroy-add-client`     | Supprime la VM AD                            |

---

## 🌐 Accès à Teleport

Après exécution de `make teleport`, tu peux accéder à Teleport :

🔗 **https://teleportnew.dhuet.cloud**

Changement de l'ip sur mon OVH me ping ;) 

> Tu peux ajouter des utilisateurs via :
```bash
kubectl exec -it -n teleport pod/<pod-auth-name> -- tctl users add <user> --roles=editor,access,auditor
```

---

## 🧼 Nettoyage

```bash
make destroy
make destroy-ubuntu-client
make destroy-add-client
```

---

## 💡 Astuces

- Le Makefile vérifie que tu es bien connecté à Azure (`az account show`)
- Utilise `terraform output` pour retrouver l'IP publique d'une VM
- Pour modifier les valeurs Helm : édite `helm/values.yaml`

