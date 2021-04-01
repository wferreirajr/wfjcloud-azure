az login


az network vnet peering create --subscription "481d6d15-6909-4298-a5f8-ef665aa523b1"  --resource-group "RG-WILSON" --name "PR-EAST-TO-WEST" --vnet-name "VNET-EAST-US" --remote-vnet "VNET-WEST-US" --allow-vnet-access --allow-forwarded-traffic

az network vnet peering create --subscription "481d6d15-6909-4298-a5f8-ef665aa523b1"  --resource-group "RG-WILSON" --name "PR-WEST-TO-EAST" --vnet-name "VNET-WEST-US" --remote-vnet "VNET-EAST-US" --allow-vnet-access --allow-forwarded-traffic


az network vnet peering list --subscription "481d6d15-6909-4298-a5f8-ef665aa523b1"  --resource-group "RG-WILSON" --vnet-name "VNET-EAST-US"
