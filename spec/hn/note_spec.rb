RSpec.describe Hn::Rollup::Note do

  let(:note) {
    Hn::Rollup::Note.new({ 'title' => 'Test 0',
                           'children' => [
                             { 'title' => 'Test 0.0',
                               'amount' => 100,
                               'children' => [
                                 { 'title' => 'Test 0.0.0',
                                   'amount' => 10 },
                                 { 'title' => 'Test 0.0.1',
                                   'amount' => 20 } ] },
                             { 'title' => 'Test 0.1',
                               'amount' => 200 } ] })
  }

  it 'aggregates children' do
    expected = { 'title' => 'Test 0',
      'children' => [
        { 'title' => 'Test 0.0',
          'amount' => 100,
          'children' => [
            { 'title' => 'Test 0.0.0',
              'amount' => 10 },
            { 'title' => 'Test 0.0.1',
              'amount' => 20 } ] },
        { 'title' => 'Test 0.1',
          'amount' => 200 } ] }

    expect(note.rollup).to eq(expected)
  end
end
