let project = new Project('Tessellation');

project.addSources('Sources');

project.addShaders('Sources/Shaders/**');

resolve(project);
