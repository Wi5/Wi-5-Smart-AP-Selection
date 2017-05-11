function ordered_locations = order_locations(locations)
  d = sqrt((locations(1,1)-locations(:,1)).^2 ...
               + (locations(1,2)-locations(:,2)).^2);
  temp1 = [[1:length(locations)]' d];
  temp2 = sortrows(temp1,2);
  ordered_locations = locations(temp2(:,1),:);
end