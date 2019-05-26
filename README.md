# SAP HANA VM Provisioning with Terraform
This template creates VM to deploy HANA database in Azure along with the necessary filesystems. If running for the first time install Terraform, create Service principal and set the environment variables as mentioned here https://docs.microsoft.com/bs-cyrl-ba/azure/virtual-machines/linux/terraform-install-configure

Customize the values in parameters.tfvars file as required and run the below terraform commands in sequence.

terraform init

terraform plan -var-file="parameters.tfvars"

terraform apply -var-file="parameters.tfvars"

This template uses the Linux SKU for SAP. 
The template takes advantage of [Custom Script Extensions](https://github.com/Azure/azure-linux-extensions/tree/master/CustomScript) for the installation and configuration of the machine. This should be used only for demonstration and sandbox environments. This is not a production deployment.

## HANA Machine Info (Pre-Configured)
The template currently deploys HANA on one of the machines listed in the table below with the noted disk configuration.  The deployment takes advantage of Managed Disks, for more information on Managed Disks or the sizes of the noted disks can be found on [this](https://docs.microsoft.com/en-us/azure/storage/storage-managed-disks-overview#pricing-and-billing) page.

Machine Size | RAM | Data and Log Disks | /hana/shared | /root | /usr/sap | hana/backup
------------ | --- | ------------------ | ------------ | ----- | -------- | -----------
E16 | 128 GB | 2 x P20 | 1 x S20 | 1 x S6 | 1 x S6 | 1 x S15
E32 | 256 GB | 2 x P20 | 1 x S20 | 1 x S6 | 1 x S6 | 1 x S20
E64 | 432 GB | 2 x P20 | 1 x S20 | 1 x P6 | 1 x S6 | 1 x S30
GS5 | 448 GB | 2 x P20 | 1 x S20 | 1 x P6 | 1 x S6 | 1 x S30

For the M series servers, this template uses the [Write Accelerator](https://docs.microsoft.com/azure/virtual-machines/linux/how-to-enable-write-accelerator) feature for the Log disks. For this reason, the log devices are separated out from the data disks:
Machine Size | RAM | Data and Log Disks | /hana/shared | /root | /usr/sap | hana/backup
------------ | --- | ------------------ | ------------ | ----- | -------- | -----------
M64s | 1TB | 4 x P20 | 2 x P20 | 1 x P30 | 1 x P6 | 1 x P6 | 2 x P30
M64ms | 1.7TB | 3 x P30 | 2 x P20 | 1 x P30 | 1 x P6 | 1 x P6 | 2 x P30
M128S | 2TB | 3 x P30 | 2 x P20 | 1 x P30 | 1 x P6 | 1 x P6 | 2 x P40
M128ms | 3.8TB | 5 x P30 | 2 x P20 | 1 x P30 | 1 x P6 | 1 x P6 | 5 x P50

