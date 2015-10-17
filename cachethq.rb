#!/usr/bin/env ruby
#
# Sensu Handler: CachetHQ
#
# This handler updates CachetHQ, creates incidents and/or updates components based on a check result.
#
# Requires: net/http
#
# Copyright 2015 Bimlendu Mishra <justbimlendu@gmail.com>
#
# Released under the same terms as Sensu (the MIT license); see LICENSE
# for details. https://github.com/sensu/sensu-community-plugins/blob/master/LICENSE

require 'rubygems' if RUBY_VERSION < '1.9.0'
require 'sensu-handler'
require 'json'
require 'net/http'
require 'uri'

## main Class
class CachetHQ < Sensu::Handler
  option :json_config,
         description: 'Configuration name',
         short: '-j JSONCONFIG',
         long: '--json JSONCONFIG',
         default: 'cachethq'

  def get_setting(name)
    settings[config[:json_config]][name]
  end

  def incident_status(op)
    status = {
      '1' => ['investigation', 'are investigating', 'investigate'], # Investigating
      '2' => ['identified', 'addressed the root cause'], # Identified
      '3' => ['monitor', 'progress'], # Watching
      '4' => ['resolved', 'operating normally', 'recover', 'restor', 'returned to normal'] # Fixed
    }

    status.each do |state, verbs|
      verbs.each do |verb|
        if op.downcase.include? verb
          incident_state = state
          return incident_state
        end
      end
    end
    '1' # default return Investigating
  end

  def verify_response(response)
    case response
    when Net::HTTPSuccess
      true
    else
      fail response.error!
    end
  end

  def check_status
    @event['check']['status']
  end

  def api_url
    get_setting('api_url')
  end

  def api_token
    get_setting('api_token')
  end

  def component_id
    @event['client']['cachethq']['component']['id'] || @event['check']['cachethq']['component']['id']
  end

  def component_name
    @event['client']['cachethq']['component']['name'] || @event['check']['cachethq']['component']['name']
  end

  def component_status
    case @event['check']['status'].to_i
    when 0, 1, 2
      comp_status = @event['check']['status'].to_i + 1
    else
      comp_status = 1
    end
    comp_status
  end

  def incident_name
    component_name + ' :: ' + @event['check']['output'].lines.first.split(':').last.strip
  end

  def incident_message
    @event['check']['output'].lines.last.strip
  end

  def check_for_duplicate_incidents(name, msg, status)
    uri = URI.parse(api_url + '/incidents')
    http = Net::HTTP.new(uri.host, uri.port)
    request = Net::HTTP::Get.new(uri.request_uri)
    response = http.request(request)
    result = JSON.parse(response.body)
    result['data'].each do |res|
      return false if res['name'] == name && res['message'] == msg && res['status'] == status
    end
    true
  end

  def update_cachet(route, data)
    uri = URI.parse(api_url + route)
    headers = { 'Content-Type' => 'application/json', 'X-Cachet-Token' => api_token }
    http = Net::HTTP.new(uri.host, uri.port)
    if route.match('components')
      request = Net::HTTP::Put.new(uri.request_uri, headers)
    elsif route.match('incidents')
      request = Net::HTTP::Post.new(uri.request_uri, headers)
    end
    request.body = data.to_json
    response = http.request(request)
    verify_response(response)
  end

  def handle
    component_route = '/components/' + component_id
    component_data = { 'status' => component_status }
    update_cachet(component_route, component_data)
    incident_route = '/incidents'
    incident_data = { 'name' => incident_name, 'message' => incident_message, 'status' => incident_status(@event['check']['output']).to_i, 'component_id' =>  component_id, 'component_status' => component_status }
    if check_for_duplicate_incidents(incident_name, incident_message, incident_status(@event['check']['output']).to_i)
      update_cachet(incident_route, incident_data)
    end
  rescue => e
    puts "Exception occured : #{e.message}", e.backtrace
  end
end
