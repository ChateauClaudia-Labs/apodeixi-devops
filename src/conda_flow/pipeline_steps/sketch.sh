

# Notes of things to do inside the container for Linux install and test


export PATH=/home/anaconda3/bin:$PATH

conda update -n base -c defaults conda

yes "y" | conda create -n test-apo-bld

conda activate test-apo-bld

conda install /home/dist/linux-64/apodeixi-0.9.8-py310_0.tar.bz2

yes " y" | conda install python

cd /home/anaconda3/envs/test-apo-bld/lib/python3.10/site-packages/apodeixi

# Need to set injected config dierctory name before running the tests, else get:
#   "Environment variable $APODEIXI_CONFIG_DIRECTORY does not point to a valid directory: 
#       '/home/anaconda3/envs/test-apo-bld/lib/python3.10/site-packages/apodeixi/testing_framework/../../../../apodeixi-testdb'"

python -m unittest

#### Then we have to repeat for windows, running in WSL to trigger work in a Windows shell

# To launch a Windows bash shell, passing a script to execute in Windows. Here is foo.sh example,
# showing that Windows bash executes in the Windows area.
# GOTCHA: environment variables need to be hard-coded in the script (e.g. APODEIXI_VERSION). Don't know of
#       another way to pass them to a WSL-invoked Windows bash.exe. Probably means that the script
#       given to Windows bash (e.g., foo.sh) needs to be copied and modified before giving it to Windows
#       for the pipeline to insert lines setting environment variables to specific values.
FOO_VERSION="9.123"
echo "cd ~/Documents && echo && echo Current directory: && pwd && echo version is \$APO_VERSION" > foo.sh
cp foo.sh foo_with_env.sh
sed -i "1s/^/export APO_VERSION=$(echo $FOO_VERSION)\n/" foo_with_env.sh
cat foo_with_env.sh
$ cat foo_with_env.sh

# The last command's result shows us we have environment variables properly injected at the top
        export APO_VERSION=9.123
        cd ~/Documents && echo && echo Current directory: && pwd && echo version is $APO_VERSION

# Now we can finally invoke the Windows bash shell:
/mnt/c/Users/aleja/Documents/CodeImages/Technos/Git/bin/bash.exe foo_with_env.sh > ~/tmp/foo_results.txt

# Results are as expected: the scripr run in Windows with correctly set environment variables
(base) alex@CCL2-Ubuntu:/tmp$ cat ~/tmp/foo_results.txt

Current directory:
/c/Users/aleja/Documents
version is 9.123
(base) alex@CCL2-Ubuntu:/tmp$

# GOTCHA: The real script that runs in Windows will use conda commands, create virtual environments, etc.
#           For that it will need to do this:
eval "$('/c/Users/aleja/Documents/CodeImages/Technos/Anaconda3/Scripts/conda.exe' 'shell.bash' 'hook')"
# Above line came from ~/.bash_profile # So that Conda is initialized, and commands like `conda activate <environment>` work

