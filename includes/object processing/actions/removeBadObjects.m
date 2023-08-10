function objects = removeBadObjects(objects, params)

goodObjects = objects.goodObjects;

objects.NumObjects = sum(goodObjects);
objects.stats = objects.stats(goodObjects);
objects.PixelIdxList = objects.PixelIdxList(goodObjects);
objects.goodObjects = goodObjects(goodObjects==1);

disp(['    - keeping ', num2str(sum(goodObjects)), ' of ', num2str(length(goodObjects)), ' cells']);