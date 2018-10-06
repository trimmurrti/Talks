require 'xcodeproj'

def add_files(folder, group_name, parent_group, target)
    updated = false

    group = parent_group[group_name]
    if group and not group_and_fs_synced?(group, folder)
        remove_group(group)
        group = nil
    end

    unless group
        group = parent_group.new_group(group_name)
        updated ||= true
    end

    refs = fs_files(folder).map do |f|
        group.new_file "#{folder}/#{f}"
    end

    target.add_file_references refs

    fs_subfolders(folder).each do |sf|
        updated = add_files("#{folder}/#{sf}", sf, group, target) || updated
    end

    updated
end

def group_and_fs_synced?(group, folder)
    files = fs_files(folder).to_set
    group_files = names_set group.files

    subfolders = fs_subfolders(folder).to_set
    group_subgroups = names_set(group.groups)

    subfolders == group_subgroups and files == group_files
end

def names_set(xc_objects)
    xc_objects
        .map { |f| f.name }
        .to_set
end

def items(folder)
    Dir.glob("#{folder}/*").select { |i| i != '.' and i != '.DS_Store'  }
end

def filtered_items(folder)
    items(folder)
        .select { |i| yield i }
        .map { |f| File.basename f }
end

def fs_files(folder)
    filtered_items(folder) { |i| File.file?(i) and i.include?(".swift") }
end

def fs_subfolders(folder)
    filtered_items(folder) { |i| File.directory? i }
end

def remove_group(group)
    group.recursive_children_groups.each do |g|
        g.files.each do |f|
            f.remove_from_project
        end
    end

    group.remove_from_project
end

def add_group_to_project(project_path, target_name, folder)
	project = Xcodeproj::Project.open(project_path)

    main_group = project.main_group
	group = main_group[folder] || main_group.new_group(folder)

	target = project.targets
        .select { |t| t.name == target_name }
        .first

	project.save if add_files folder, folder, project.main_group, target
end

add_group_to_project ENV["PROJECT_FILE_PATH"], ENV["TARGET_NAME"], 'Generated'
