namespace :elasticsearch do
  desc 'Create all Elasticsearch indices'
  task create_indices: :environment do
    [ Project, Task ].each do |model|
      puts "Creating index for #{model.name}"
      model.create_index!
      puts "Index for #{model.name} created successfully"
    end
  end

  desc 'Import data into Elasticsearch'
  task import_data: :environment do
    [ Project, Task ].each do |model|
      puts "Importing data for #{model.name}"
      model.import_data
      puts "Data for #{model.name} imported successfully"
    end
  end

  desc 'Reindex all models (drop, create and import)'
  task reindex: [ :create_indices, :import_data ] do
    puts 'Reindexing completed'
  end
end
