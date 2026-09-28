import os
import sys
import json

def get_duplicates(root_path):
    files_metadata = {}
    
    # 1. Standardize path for Windows
    root_path = os.path.abspath(root_path)
    
    if not os.path.exists(root_path):
        return {"error": f"Path not found: {root_path}", "duplicates": []}

    # 2. Add error handling to os.walk to skip forbidden folders
    for root, dirs, files in os.walk(root_path, topdown=True, onerror=None):
        # Prevent walking into hidden or system folders that cause hangs
        dirs[:] = [d for d in dirs if not d.startswith('.')] 
        
        for filename in files:
            file_path = os.path.join(root, filename)
            try:
                # Use file size and extension
                file_size = os.path.getsize(file_path)
                file_ext = os.path.splitext(filename)[1].lower()
                
                meta_key = f"{file_size}_{file_ext}"

                if meta_key in files_metadata:
                    files_metadata[meta_key].append(file_path)
                else:
                    files_metadata[meta_key] = [file_path]
            except (OSError, PermissionError):
                # Skip files we can't read
                continue

    duplicates_list = [
        {"metadata": key, "paths": paths} 
        for key, paths in files_metadata.items() if len(paths) > 1
    ]

    return {
        "scan_complete": True,
        "total_duplicates_found": sum(len(d["paths"]) - 1 for d in duplicates_list),
        "duplicates": duplicates_list
    }

if __name__ == "__main__":
    # 3. Ensure we handle the argument correctly
    try:
        target_path = sys.argv[1] if len(sys.argv) > 1 else os.path.expanduser("~/Documents")
        
        scan_result = get_duplicates(target_path)
        
        # 4. CRITICAL: Use flush=True so Flutter doesn't wait forever
        # Remove indent=2 to make the JSON string easier for Dart to read in one go
        print(json.dumps(scan_result), flush=True)
        
    except Exception as e:
        # If the whole script dies, tell Flutter why
        print(json.dumps({"error": str(e)}), flush=True)
        sys.exit(1)