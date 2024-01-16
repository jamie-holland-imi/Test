# Actions_Template
Template Repository that builds and runs a docker image including a static analysis workflow.

The branch makefile contains an example Makefile for an STM32 project using the ARM GNU Toolchain
In makefile use verision to access the git tag that is passed in.

The branch cmock contains an example cmock action that installs cmock and runs some example tests that come with the cmock repository.

# Instructions
Firstly, go to your GitHub cloud repositories page and select the NEW button to create a new repository, within the Create a new repository page:
  1.	Select the repository template you wish to use.
  2.	Set the owner to either yourself or your organisation depending on if it is a personal or organisational project.
  3.	The repository name must match the IDE project name that you have or will create.
  4.	Company projects are set as default to Internal, however personal projects can be set to either Public or Private.
  5.	The template comes with a .gitignore files so you can ignore that option.
  6.	Finally select Create repository.
This will generate a new repository containing a copy of the templates files ready to be modified if needed for a new project.
