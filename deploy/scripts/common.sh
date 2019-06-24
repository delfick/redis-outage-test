echo -e "=== CHECK CONTEXT"
echo "context: $(kubectl config current-context)"

while true; do
    read -p "Is this the correct context?" yn
    case $yn in
        [Yy]* ) break;;
        [Nn]* ) exit 1;;
        * ) echo "Please answer yes or no.";;
    esac
done

export NAMESPACE=redisoutagetest
