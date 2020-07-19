  
#!/bin/sh
# install driver first, if this is a gpu node: 
# bash <(curl -s https://raw.githubusercontent.com/L1NNA/L1NNA-peppapig/master/setup_slack.sh)

export KUBECONFIG=$HOME/admin.conf

helm repo add infracloudio https://infracloudio.github.io/charts
helm repo update

echo "you need to obtain your slack api token by installing this app to your workspace:"
echo "https://slack.com/apps/AF5DZLHPC-botkube"
echo "please also review their privacy policy for current version"
echo "https://www.botkube.io/privacy/"
read -p "Enter slack api token: " SLACK_API_TOKEN_FOR_THE_BOT
read -p "Enter slack channel name: " SLACK_CHANNEL_NAME

ALLOW_KUBECTL="yes"
read -e -i "$ALLOW_KUBECTL" -p "Allow kubectl? (true/false): " input
ALLOW_KUBECTL="${input:-$ALLOW_KUBECTL}"

CLUSTER_NAME=peppa-pig

helm install --version v0.10.0 --name botkube --namespace botkube --set communications.slack.enabled=true --set communications.slack.channel=$SLACK_CHANNEL_NAME --set communications.slack.token=$SLACK_API_TOKEN_FOR_THE_BOT --set config.settings.clustername=$CLUSTER_NAME --set config.settings.allowkubectl=$ALLOW_KUBECTL --set image.repository=infracloudio/botkube --set image.tag=v0.10.0 infracloudio/botkube
  
kubectl get pods -n infracloudio
  
