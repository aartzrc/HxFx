let project = new Project('HxFx');
project.addAssets('Assets/**');
project.addSources('Sources');

project.addLibrary('bindx2');

//project.addParameter('-main tests.SimpleWindow');
//project.addParameter('-main tests.ScaleGridWindow');
//project.addParameter('-main tests.FixedGridWindow');
//project.addParameter('-main tests.DualGridWindow');
//project.addParameter('-main tests.ScrollableWindow');
//project.addParameter('-main tests.ComponentWindow');
//project.addParameter('-main tests.BorderContainerWindow');
project.addParameter('-main tests.ScrollContainerWindow');

resolve(project);
