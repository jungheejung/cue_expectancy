import subprocess

def get_git_top_dir():
    try:
        # Execute the git command to find the top-level directory
        result = subprocess.run(["git", "rev-parse", "--show-toplevel"], stdout=subprocess.PIPE, stderr=subprocess.PIPE, check=True, text=True)
        # Strip newline character from the output to get the clean path
        top_dir = result.stdout.strip()
        return top_dir
    except subprocess.CalledProcessError as e:
        # Handle errors (e.g., if the current directory is not part of a Git repository)
        print(f"Error: {e.stderr}")
        return None