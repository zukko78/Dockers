/var/lib/docker/containers/*/*.log{
rotate {{ logrotate_count }}
daily
compress
size={{ logrotate_size }}
missingok
copytruncate
}
