#!C:/opt/sensu/embedded/bin/ruby.exe
require 'sensu-plugin/metric/cli'
require 'socket'

class FileCacheMissesMetric < Sensu::Plugin::Metric::CLI::Graphite
  option :scheme,
         description: 'Metric naming scheme, text to prepend to .$parent.$child',
         long: '--scheme SCHEME',
         default: Socket.gethostname.to_s
  option :app,
         description: 'For W3SVC_W3WP, you need to put WorkerProcessID_AppPoolName. ex: 14604_DefaultAppPool',
         short: '-a APP',
         long: '--apppool APP',
         default: '_TOTAL'

  def accquire_File_Cache_Misses
    temp_arr = []
    timestamp = Time.now.utc.to_i
    IO.popen("typeperf -sc 1 \"\\W3SVC_W3WP(#{config[:app]})\\File Cache Misses\"") { |io| io.each { |line| temp_arr.push(line) } }
    temp = temp_arr[2].split(',')[1]
    metric = temp[1, temp.length - 3].to_f
    [metric, timestamp]
  end

  def run
    values = accquire_File_Cache_Misses
    metrics = {
      WorkerProcessCache: {
        FileCacheMisses: values[0]
      }
    }
    metrics.each do |parent, children|
      children.each do |child, value|
        output [config[:scheme], parent, child].join('.'), value, values[1]
      end
    end
    ok
  end
end
