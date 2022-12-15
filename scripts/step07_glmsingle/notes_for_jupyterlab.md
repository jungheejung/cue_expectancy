# login to discovery
conda activate spacetop_env
jupyter notebook --no-browser

# at the end of the terminal
To create the tunnel, you need to find out what port JNB is running on. That information is embedded in the output that was displayed when launching JNB in Step 2. The port number is the 4 digit integer (XXXX) that comes in http://localhost:XXXX or in http://127.0.0.1:XXXX.

# open new terminal and login
ssh -NfL XXXX:127.0.0.1:XXXX f0042x1@polaris.dartmouth.edu

# copy url from original jupyterlab terminal and past to browser
If you go back to the terminal window running JNB and copy the localhost URL at the bottom, and paste it in your favorite browser's URL bar: