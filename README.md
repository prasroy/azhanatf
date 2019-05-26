# SAP HANA VM Provisioning with Terraform
This template creates VM to deploy HANA database in Azure along with the necessary filesystems. If running for the first time install Terraform, create Service principal and set the environment variables as mentioned here https://docs.microsoft.com/bs-cyrl-ba/azure/virtual-machines/linux/terraform-install-configure

Customize the values in parameters.tfvars file as required and run the below terraform commands in sequence.

terraform init

terraform plan -var-file="parameters.tfvars"

terraform apply -var-file="parameters.tfvars"

This template uses the Linux SKU for SAP HANA. 
The template takes advantage of [Custom Script Extensions](https://github.com/Azure/azure-linux-extensions/tree/master/CustomScript) for the installation and configuration of the machine. This should be used only for demonstration and sandbox environments. This is not a production deployment.

## HANA Machine Info (Pre-Configured)
The template currently deploys HANA on one of the machines listed in the table below with the noted disk configuration.  The deployment takes advantage of Managed Disks, for more information on Managed Disks or the sizes of the noted disks can be found on [this](https://docs.microsoft.com/en-us/azure/storage/storage-managed-disks-overview#pricing-and-billing) page.

Machine Size | RAM | Max VM I/O Throughput |Data and Log Disks | /hana/shared | /root | /usr/sap | hana/backup
------------ | --- | -------------- | ------------ | ------- | ------ | ------- | ---------
E16v3 | 128 GB | 384MB/s | 2 x P20 | 1 x S20 | 1 x S6 | 1 x S6 | 1 x S15
E32v3 | 256 GB | 768MB/s | 2 x P20 | 1 x S20 | 1 x S6 | 1 x S6 | 1 x S20
E64v3 | 432 GB | 1200MB/s | 3 x P20 | 1 x S20 | 1 x P6 | 1 x S6 | 1 x S30
GS5 | 448 GB | 2000MB/s | 3 x P20 | 1 x S20 | 1 x P6 | 1 x S6 | 1 x S30

For the M series servers, this template uses the [Write Accelerator](https://docs.microsoft.com/azure/virtual-machines/linux/how-to-enable-write-accelerator) feature for the Log disks. For this reason, the log devices are separated out from the data disks.

Machine Size | RAM | Data Disks | Log disks| /hana/shared | /root | /usr/sap | hana/backup
------------ | --- | ------------------ | ------------------ |------------ | ----- | -------- | -----------
M32ts | 192GB | 3 x P20 | 2 x P20 | 1 x P20 | 1 x P6 | 1 x P6 | 2 x P15
M32ls | 256GB | 3 x P20 | 2 x P20 | 1 x P20 | 1 x P6 | 1 x P6 | 2 x P15
M64lS | 512GB | 3 x P20 | 2 x P20 | 1 x P20 | 1 x P6 | 1 x P6 | 2 x P20
M64s | 1TB | 4 x P20 | 2 x P20 | 1 x P30 | 1 x P6 | 1 x P6 | 2 x P30
M64ms | 1.7TB | 3 x P30 | 2 x P20 | 1 x P30 | 1 x P6 | 1 x P6 | 2 x P30
M128S | 2TB | 3 x P30 | 2 x P20 | 1 x P30 | 1 x P6 | 1 x P6 | 2 x P40
M128ms | 3.8TB | 5 x P30 | 2 x P20 | 1 x P30 | 1 x P6 | 1 x P6 | 5 x P50
M208S_V2 | 2.85TB | 4 x P30 | 2 x P20 | 1 x P30 | 1 x P6 | 1 x P6 | 3 x P40
M208ms_V2 | 5.7TB | 4 x P40 | 2 x P20 | 1 x P30 | 1 x P6 | 1 x P6 | 5 x P50

## Configuring for SAP HANA DATA and LOG Disks
Virtual Machines for SAP HANA need to have specific storage configuration as mentioned below:

Enable read/write volume on /hana/log of a 250 MB/sec at minimum with 1 MB I/O sizes
Enable read activity of at least 400 MB/sec for /hana/data for 16 MB and 64 MB I/O sizes
Enable write activity of at least 250 MB/sec for /hana/data with 16 MB and 64 MB I/O sizes

Therefore, it is mandatory to leverage Azure Premium Disks for /hana/data and /hana/log volumes.
As stripe sizes for the RAID 0 the recommendation is to use:

64 KB or 128 KB for /hana/data

32 KB for /hana/log

## Caching recommendations on storage for SAP HANA

/hana/data - no caching

/hana/log - no caching - exception for M-Series (see later in this document)

/hana/shared - read caching