/*
  Lag et personal accesstoken med rettighetene read:org og user:follow
  Enable sso og authorize mot Nav
  Installer avhengigheter $ npm i axios then-sleep
  Legg inn token value i personalToken og GitHub username i githubUsername
  kjør scriptet $ node colleagues.js og vent :-)
*/
(async () => {
  const axios = require('axios')
  const open = require('open')
  const sleep = require('then-sleep')
  const githubUsername = '<your-github-username>'
  const personalToken = '<your-personal-token>'
  const baseUrl = 'https://api.github.com/orgs/navikt/teams/nav-developers/members'
  const token = Buffer.from(`${githubUsername}:${personalToken}`).toString('base64')
  axios.defaults.headers.common.Authorization = `Basic ${token}`

  const colleagues = []
  let page = 0
  let gotColleagues = true

  console.log('start looking for colleagues')

  while (gotColleagues === true) {
    page++
    const url = `${baseUrl}?page=${page}&per_page=100`
    const { data: retrievedColleagues } = await axios.get(url)
    console.log(`retrieved ${retrievedColleagues.length}`)
    colleagues.push(...retrievedColleagues)
    if (retrievedColleagues.length === 0) {
      gotColleagues = false
    }
  }

  console.log(`total colleagues: ${colleagues.length}`)

  while (colleagues.length > 0) {
    const colleague = colleagues.pop()
    const { login: username } = colleague
    console.log(`following ${username}`)
    const followUrl = `https://api.github.com/user/following/${username}`
    await axios.put(followUrl)
    console.log(`only ${colleagues.length} to go`)
    await sleep(500)
  }
  console.log('Everyone is added')
})()
