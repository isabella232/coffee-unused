pistachios =
  ///
  \{                  # first { (begins symbol)
    ([\w|-]*)?        # optional custom html tag name
    (\#[\w|-]*)?      # optional id - #-prefixed
    ((?:\.[\w|-]*)*)  # optional class names - .-prefixed
    (\[               # optional [ begins the attributes
      (?:\b[\w|-]*\b) # the name of the attribute
      (?:\=           # optional assignment operator =
                      # TODO: this will tolerate fuzzy quotes for now. "e.g.'
        [\"|\']?      # optional quotes
        .*            # optional value
        [\"|\']?      # optional quotes
      )
    \])*              # optional ] closes the attribute tag(s). there can be many attributes.
    \{                # second { (begins expression)
      ([^{}]*)        # practically anything can go between the braces, except {}
    \}\s*             # closing } (ends expression)
  \}                  # closing } (ends symbol)
  ///g


DATA_REGEX = /#\(([^)]*)\)/g

getData = (s) -> s[2...s.length-1]

module.exports = {
  pistachios
  DATA_REGEX
  getData
}