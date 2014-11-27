require 'net/http'
require 'json'

placeholder = '/assets/nyantocat.gif'
subreddits = {
  'boston' => '/r/bostonterrier/hot.json?limit=100',
  'aww' => '/r/aww_gifs/hot.json?limit=100',
  'puppy' => '/r/puppygifs/hot.json?limit=100',
  'dog_gif' => '/r/doggifs/hot.json?limit=100',
  'pug_gif' => '/r/Puggifs/hot.json?limit=100',
  'duck' => '/r/babyduckgifs/hot.json?limit=100'

}

SCHEDULER.every '10s', first_in: 0 do |job|
  subreddits.each do |widget_event_id, subreddit|
    http = Net::HTTP.new('www.reddit.com')
    response = http.request(Net::HTTP::Get.new(subreddit))
    json = JSON.parse(response.body)

    if json['data']['children'].count <= 0
      send_event('aww', image: placeholder)
    else
      urls = json['data']['children'].map{|child| child['data']['url'] }

      # Ensure we're linking directly to an image, not a gallery etc.
      valid_urls = urls.select{|url| url.downcase.end_with?('png', 'gif', 'jpg', 'jpeg')}
      send_event(widget_event_id, image: "background-image:url(#{valid_urls.sample(1).first})")
    end
  end
end
