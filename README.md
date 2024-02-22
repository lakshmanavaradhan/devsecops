# devsecops
```project to print IP in revese and inline with secops pratices```
![image](https://github.com/lakshmanavaradhan/devsecops/assets/17141515/f448dcef-2c75-4b82-b1ef-f4335f1c2b86)
```pipeline has three stages```
1. secret scan -> to check sensective info commited to repo
   ```tool - detect-secrets | for production usecase trufflehog best which has addition polciy features!!```
2. CI_CD ->  to build docker image, scan docker image and k8 spec file
   ```trivity, docker, kubescanner```
3. IaC -> to setup infra in AWS using Teraform and  scan tempalte for best practies and figure out misconfirgurations ```tflint, checkov```

FOR APPSEC ( SAST,DAST,SCA,THREAT_MODELING ) kindly ref - https://github.com/lakshmanavaradhan/hyperswitch-react-node
