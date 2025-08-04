- install salesforce cli
- dev hub should be enabled in your org
- install git

Clone repo
```
- git clone https://github.com/txtxps/billieTest.git
- cd billieTest
```

Authenticate to Dev Hub
```
sfdx auth:web:login --setdefaultdevhubusername --setalias [YourOrgAlias]
sf org login web --set-default-dev-hub --alias [YourOrgAlias]
```

(optional) Create a scratch org
```
sf org create scratch --definition-file config/project-scratch-def.json --alias [YourScratchOrgAlias] --set-default
```

create the package
```
sf package create --name "BillieUnlockedPackage" --description "Billie unlocked package" --package-type Unlocked --path force-app

```
create a version
```
sf package version create --package BillieUnlockedPackage --installation-key-bypass --code-coverage --wait 20

```
install package
```
sf package install --package [04tgL0000004XobQAE] --target-org [YourOrgAlias] --wait 15 --publish-wait 15 --noprompt
```

- fill in custom settings “Various Settings” with your endpoint
- add endpoint to remote site settings

create app page or add the custom component to the existing page

Testing
1. navigate to the app page
2. click on the “yourNameTab” tab
3. trigger logic via UI button