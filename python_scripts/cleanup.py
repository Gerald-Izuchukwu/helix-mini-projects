import subprocess

def cleanup():
    print("Running in dry mode: No files will be deleted")
    result = subprocess.run(["ls"], capture_output=True, text=True)
    if result.returncode != 0:
        print("Error listing files:", result.stderr)
        return
    files = result.stdout.splitlines()

    print("Files in current directory before cleanup:")
    print(result.stdout)
    print(f"{len(files)} files found.\n")

    for file in files:
        if file.endswith(".log") or file.endswith(".tmp"):
            print(f"FOUND: {file} - Ready for deletion.")
cleanup()