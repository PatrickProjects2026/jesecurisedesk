import os
import shutil
import sys

def manage_duplicates(root_path):
    quarantine_folder = os.path.join(root_path, "quarantine_folder")
    
    # dictionary key: (size, extension) -> value: [list of file paths]
    files_metadata = {}
    duplicates = []

    print(f"--- Scanning directory: {root_path} ---")

    for root, _, files in os.walk(root_path):
        # Skip the quarantine folder itself to avoid infinite loops/scanning
        if "quarantine_folder" in root:
            continue
            
        for filename in files:
            file_path = os.path.join(root, filename)
            try:
                file_size = os.path.getsize(file_path)
                file_ext = os.path.splitext(filename)[1].lower()
                
                meta_key = (file_size, file_ext)

                if meta_key in files_metadata:
                    files_metadata[meta_key].append(file_path)
                    duplicates.append(file_path)
                else:
                    files_metadata[meta_key] = [file_path]
            except OSError:
                continue

    if not duplicates:
        return "Scan Complete: No duplicates found."

    print(f"Found {len(duplicates)} duplicate files.")
    choice = input("Option: [M]ove to quarantine, [D]elete, or [C]ancel? ").strip().lower()

    if choice == 'm':
        if not os.path.exists(quarantine_folder):
            os.makedirs(quarantine_folder)
        for file in duplicates:
            try:
                shutil.move(file, os.path.join(quarantine_folder, os.path.basename(file)))
            except Exception as e:
                print(f"Error moving {file}: {e}")
        return f"Success: Moved {len(duplicates)} files to {quarantine_folder}."

    elif choice == 'd':
        confirm = input("Are you sure you want to permanently DELETE? (y/n): ")
        if confirm.lower() == 'y':
            for file in duplicates:
                os.remove(file)
            return f"Success: Deleted {len(duplicates)} files."
    
    return "Operation cancelled."

if __name__ == "__main__":
    # Use provided path or default to Documents
    target_path = sys.argv[1] if len(sys.argv) > 1 else r"C:\Users\IT012.DOTCOM\Documents\\"
    
    if os.path.exists(target_path):
        result = manage_duplicates(target_path)
        print(result)
    else:
        print("Error0: The specified path does not exist.")