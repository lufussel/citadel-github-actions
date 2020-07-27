# citadel-github-actions

A lab to demonstrate an implementation of GitHub Actions with Terraform, including GitHub project boards and issues.

# Example GitHub Actions pipeline with Terraform

This lab is intended as a basic example to get started with using the GitHub Actions, issues and project board functionality with Terraform infrastructure as code.

During this lab, we will create:
- A branching strategy to test and deploy to Azure environments.
- A pipeline to deploy to a dev/pre-prod environment.
- A pipeline to deploy to a production environment from a production branch.
- A projects board to capture Issues and to associate pull requests.

# Contents

Lab | Name                                                            | Description
--- | --------------------------------------------------------------- | ----------- 
1   | [Lab prerequisites](./1-prerequisites/)                         | Setup Terraform environment
2   | [Prepare a GitHub repository](./2-prepare-a-github-repository/) | Create a GitHub repo and enable branch protection
3   | [Create a GitHub project board](./3-create-a-github-project-board/)         | Create a GitHub project board to show automation integration
4   | [Add Terraform code](./4-add-terraform-code/)                   | Import a basic Terraform template to demonstrate deployment
5   | [Create a GitHub action](./5-create-github-action/)             | Create a GitHub Action to deploy the Terraform code
6   | [Create a production branch](./6-create-a-production-branch/)   | Create an additional branch to demonstrate GitHub Actions across branches


# Architecture

`INSERT DIAGRAM`

