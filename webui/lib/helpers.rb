###############################################################################
# helpers
###############################################################################

module Dash::Helpers
  include Dash::Models

  def cluster_link(cluster)
    "/cluster/#{cluster}"
  end

  def append_query_string(str)
    v = str.dup
    query = request.query_string
    (v << "?#{query}") unless request.query_string.empty?
    return v
  end

  def status(check)
    j = check.status == Host::OK ? "ok" : "fail"
    "<#{j}>#{check.status}</#{j}> #{bugzilla_link(check) if j=="fail" }"
  end

  def css_url
    style = File.join(settings.root, "public/style.css")
    mtime = File.mtime(style).to_i.to_s
    return \
    %Q[<link href="/style.css?#{mtime}" rel="stylesheet" type="text/css">]
  end

  def aggregate_bugzilla(check)
    url = settings.config.global_config[:bugzilla_url]
    h_url = settings.config.global_config[:hostlint_url]
    failing = Host.hosts_failing(@check)
    succeeding = Host.hosts_succeeding(@check)
    fields = { :short_desc => "[hostlint] hosts failing #{check}",
      :comment => "#{failing.size}/#{failing.size + succeeding.size} hosts failing at report time (#{Time.now}).
See http://#{h_url}/check/#{check}",
      :keyword => ""
    }
    url_parts = []
    fields.each do |k, v|
      [v].flatten.each do |v|
        url_parts << "#{URI.escape(k.to_s)}=#{URI.escape(v.to_s)}"
      end
    end
    url += "&" + url_parts.join("&")
    "<a href=\"#{url}\" target=\"_blank\" style=\"font-size:small;\">file a bug</a>"

  end

  def bugzilla_link(check)
    # info should have host, cluster, report_time
    url = settings.config.global_config[:bugzilla_url]
    h_url = settings.config.global_config[:hostlint_url]
    fields = { :short_desc => "[hostlint ##{check.hostlint_id}] " +
      "#{check.host}.#{check.cluster}: #{check.name}",
      # fixme fuck URI.join etc.
      :comment => "hostlint link: http://#{h_url}/check/#{check.name}##{check.hostlint_id}
#{check.body}",
      :keyword => ""
    }
    url_parts = []
    fields.each do |k, v|
      [v].flatten.each do |v|
        url_parts << "#{URI.escape(k.to_s)}=#{URI.escape(v.to_s)}"
      end
    end
    url += "&" + url_parts.join("&")
    "<a href=\"#{url}\" target=\"_blank\" style=\"font-size:small;\">file a bug</a>"
  end

  def hostlink(host)
    "<a href=\"/host/#{host.cluster}/#{host}\">#{host}</a>"
  end

  def checklink(check)
    "<a href=\"/check/#{check}\">#{check}</a>"
  end

  # fixme when colos have the same hostnames
  def hosts_selector(hosts)
    @hosts = hosts
    erb :'partials/hosts_selector', :layout => false
  end

  def status_selector()
    erb :'partials/status_selector', :layout => false
  end

  def stats_helper(check)
    succeeding = (Host.check_map[check][Host::OK]||[]).size
    failing = (Host.check_map[check][Host::FAIL]||[]).size
    if failing == 0
      "all hosts pass<br>"
    else
      "#{failing}/#{succeeding + failing} hosts failing<br>"
    end
  end

  def host_helper(host)
    succeeding = host.checks_succeeding.size
    failing = host.checks_failing.size
    if failing != 0
      "#{failing}/#{succeeding + failing} checks failing"
    end
  end

  def check_status_to_hosts_map
    bucket = {}
    @hosts.each do |h|
      type = @status == Host::OK ? :checks_succeeding : :checks_failing
      h.send(type).each do |c|
        bucket[c.name] ||= []
        bucket[c.name] << h
      end
    end
    bucket
  end
end

###############################################################################
