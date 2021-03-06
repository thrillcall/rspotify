describe RSpotify::Playlist do

  # Keys generated specifically for the tests. Should be removed in the future
  let(:client_id) { '5ac1cda2ad354aeaa1ad2693d33bb98c' }
  let(:client_secret) { '155fc038a85840679b55a1822ef36b9b' }
  let(:starred_playlist) do
    VCR.use_cassette('playlist:find:118430647:starred') do
      RSpotify::Playlist.find('118430647', 'starred')
    end
  end

  before do
    VCR.use_cassette('authenticate:5ac1cda2ad354aeaa1ad2693d33bb98c') do
      RSpotify.authenticate(client_id, client_secret)
    end
  end

  describe 'Playlist::find' do

    let(:playlist) do
      # Get wizzler's "Movie Soundtrack Masterpieces" playlist as a testing sample
      VCR.use_cassette('playlist:find:wizzler:00wHcTN0zQiun4xri9pmvX') do
        RSpotify::Playlist.find('wizzler', '00wHcTN0zQiun4xri9pmvX')
      end
    end

    it 'should find playlist with correct attributes' do
      expect(playlist.collaborative)            .to eq    false
      expect(playlist.external_urls['spotify']) .to eq    'http://open.spotify.com/user/wizzler/playlist/00wHcTN0zQiun4xri9pmvX'
      expect(playlist.description)              .to match /Iconic soundtracks featured in some of the greatest movies/
      expect(playlist.followers['total'])       .to be    > 0
      expect(playlist.href)                     .to eq    'https://api.spotify.com/v1/users/wizzler/playlists/00wHcTN0zQiun4xri9pmvX'
      expect(playlist.id)                       .to eq    '00wHcTN0zQiun4xri9pmvX'
      expect(playlist.images.first['url'])      .to match %r{https://dv72vokf4bztv\.cloudfront}
      expect(playlist.name)                     .to eq    'Movie Soundtrack Masterpieces'
      expect(playlist.public)                   .to eq    true
      expect(playlist.type)                     .to eq    'playlist'
      expect(playlist.uri)                      .to eq    'spotify:user:wizzler:playlist:00wHcTN0zQiun4xri9pmvX'
    end

    it 'should find playlist with correct owner' do
      owner = playlist.owner
      expect(owner)    .to be_an RSpotify::User
      expect(owner.id) .to eq 'wizzler'
    end

    it 'should find playlist with correct tracks' do
      tracks = playlist.tracks
      expect(tracks)             .to be_an Array
      expect(tracks.size)        .to eq 50
      expect(tracks.first)       .to be_an RSpotify::Track
      expect(tracks.map(&:name)) .to include('Waking Up', 'Honor Him', 'Circle of Life', 'Time')
    end

    context 'starred playlist' do
      it "should support starred playlists" do
        expect(starred_playlist.name).to  eq "Starred"
        expect(starred_playlist.href).to   eq "https://api.spotify.com/v1/users/118430647/starred"
      end
    end
  end

  describe 'Playlist#tracks' do
    it 'should fetch more tracks correctly' do
      tracks = VCR.use_cassette('playlist:tracks:118430647:starred') do
        starred_playlist.tracks(offset: 100, limit: 100)
      end
      expect(tracks)           .to be_an Array
      expect(tracks.size)      .to eq 83
      expect(tracks.last.name) .to eq 'Blowfish - Lake People Remix'
    end
  end

  describe 'Playlist#complete!' do
    let(:href) { 'https://api.spotify.com/v1/users/wizzler/playlists/00wHcTN0zQiun4xri9pmvX' }
    let(:playlist) { RSpotify::Playlist.new('href' => href, 'owner' => {'id' => 'wizzler'}) }

    it 'should fetch the complete information correctly' do
      VCR.use_cassette('playlist:find:wizzler:00wHcTN0zQiun4xri9pmvX') do
        playlist.complete!
      end
      expect(playlist.name).to eq 'Movie Soundtrack Masterpieces'
    end
  end
end
