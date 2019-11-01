#!/bin/bash

# Create the storage tree if needed and fix permissions
cp -r storage.skel/* storage/
chown -R www-data:www-data storage/ bootstrap/cache/
gosu www-data:www-data php artisan storage:link

# Cache config and routes
gosu www-data:www-data php artisan config:cache
gosu www-data:www-data php artisan route:cache

# Migrate database if the app was upgraded
gosu www-data:www-data php artisan migrate --force

# Run other specific migratins if required
gosu www-data:www-data php artisan update

# Run a worker if it is set as embedded
if [ "$HORIZON_EMBED" = "true" ]; then
  gosu www-data:www-data php artisan horizon &
fi

# Finally run Apache
exec apache2-foreground
