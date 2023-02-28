def glob_folder_sub(top_dir):
    import os
    """
    get list of folders that start with sub-
    """
    sub_folders = next(os.walk(top_dir))[1]
    sub_list = [i for i in sub_folders if i.startswith('sub-')]