# Packer Multi-Cloud Image Template with Ubuntu and Nginx

This repository contains a **Packer template** designed to automate the creation of images for multi-cloud environments (AWS and potentially extendable to Google Cloud). The images include **Ubuntu** as the operating system and pre-configure **Nginx** as a web server alongside a Node.js application.

## Features

- Creates an Amazon Machine Image (AMI) with Ubuntu and Nginx.
- Configures a basic Node.js application serving a "Hello World" response.
- Prepares the AMI for multi-cloud usage with minimal adjustments.
- Associates a public IP address for easy access.

## Prerequisites

Before using this template, ensure you have the following:

1. [Packer](https://www.packer.io/downloads) installed on your local machine.
2. An AWS account with a user that has **EC2 permissions**, specifically:
   - `ec2:DescribeImages`
   - `ec2:CreateImage`
   - `ec2:RunInstances`
   - `ec2:TerminateInstances`
   - `ec2:DescribeInstanceStatus`
3. AWS credentials configured on your local machine.

### Setting up AWS Credentials

Use the AWS CLI to configure your credentials:

```bash
aws configure

### AWS CLI Configuration
You will be prompted to enter:
- **Access Key ID**
- **Secret Access Key**
- **Default region** (e.g., `us-east-1`)
- **Default output format** (e.g., `json`)
```

Ensure the IAM user you're using has the required EC2 permissions.

### Usage

1. **Clone this repository**:

   ```bash
   git clone <repository-url>
   cd <repository-directory>
    ```

### Customize the Template Variables if Needed

Edit the `ami_id`, `aws_region`, or `instance_type` in the `packer.json` file as per your requirements.

### Validate the Packer Template

```bash
packer validate <template-filename>.json
```

### Build the Image Using Packer

```bash
packer build <template-filename>.json
```
### Completion

Once the build is complete, you will see the **AMI ID** in the output. This AMI can now be used to launch an EC2 instance.

### Accessing the Application

1. **Launch an EC2 Instance**

   Use the newly created AMI to launch an instance.

2. **Set Up the Security Group**

   Ensure the instance's security group allows inbound traffic on port `80` (HTTP).

3. **Access the Application**
   - Copy the **public IP address** of the instance.
   - Open the IP address in a web browser.
   - Use HTTP intead of HTTPS.
   - You should see a "Hello World!" message.

---

### Notes

- This template is pre-configured to associate a public IP address with the EC2 instance.
- Extendability for Google Cloud requires modifying the `source` and adding additional provisioning logic.

---

### License

This project is licensed under the **MIT License**. See the [LICENSE](./LICENSE) file for details.
