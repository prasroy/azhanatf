#!/bin/bash
#   VMSize="Standard_E16s_v3 (128 GB)" \
#Standard_M128ms (3.8 TB, Certified)
set -x
echo "Reading config...." >&2
if [ "${1}" != "" ]; then
    source ${1}
else
    source ./azuredeploy.cfg
fi

#hanavmsize="Standard_E16s_v3 (128 GB)"
#hanavmsize="Standard_M128s (2 TB, Certified)"

az group create --name $rgname  --location "${location}"

echo "creating hana cluster"
az group deployment create \
--name HANADeployment \
--resource-group $rgname \
   --template-uri "https://raw.githubusercontent.com/AzureCAT-GSI/SAP-HANA-ARM/master/azuredeploy.json" \
   --parameters \
   HanaVersion="SAP HANA PLATFORM EDITION 2.0 SPS03 REV30 (51053061)" \
   VMName="hana1" \
   HANAJumpbox="yes" \
   VMSize="Standard_E16s_v3 (128 GB)" \
   customURI="${customuri}" \
   VMUserName=$vmusername \
   VMPassword=$vmpassword \
   OperatingSystem="SLES for SAP 12 SP3" \
   IPAllocationMethod="Static" \

echo "hana cluster created"
