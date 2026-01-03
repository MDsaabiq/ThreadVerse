#!/usr/bin/env node

import axios from 'axios';

const BASE_URL = 'http://localhost:4000/api/v1';

async function test() {
  try {
    // Step 1: Create a user and get token
    console.log('1. Signing up...');
    const signupRes = await axios.post(`${BASE_URL}/auth/signup`, {
      username: 'testuser' + Date.now(),
      email: `test${Date.now()}@example.com`,
      password: 'password123'
    });
    const token = signupRes.data.accessToken;
    console.log('✓ Signup successful');
    console.log('Token:', token);

    // Step 2: Create a community
    console.log('\n2. Creating a community...');
    const communityRes = await axios.post(`${BASE_URL}/communities`, {
      name: 'test' + Date.now(),
      description: 'Test community',
      isPrivate: false,
      isNsfw: false,
      allowedPostTypes: ['text', 'link', 'image', 'poll']
    }, {
      headers: { Authorization: `Bearer ${token}` }
    });
    const communityName = communityRes.data.community.name;
    console.log('✓ Community created:', communityName);

    // Step 3: Create a text post in community
    console.log('\n3. Creating a text post in community...');
    const postRes1 = await axios.post(`${BASE_URL}/posts`, {
      community: communityName,
      title: 'Test post in community',
      type: 'text',
      body: 'This is a test post'
    }, {
      headers: { Authorization: `Bearer ${token}` }
    });
    console.log('✓ Post created in community:', postRes1.data.post._id);

    // Step 4: Create a text post (public/no community)
    console.log('\n4. Creating a public text post...');
    const postRes2 = await axios.post(`${BASE_URL}/posts`, {
      title: 'Public test post',
      type: 'text',
      body: 'This is a public post without community'
    }, {
      headers: { Authorization: `Bearer ${token}` }
    });
    console.log('✓ Public post created:', postRes2.data.post._id);

    // Step 5: Create a link post
    console.log('\n5. Creating a link post...');
    const postRes3 = await axios.post(`${BASE_URL}/posts`, {
      title: 'Link post',
      type: 'link',
      linkUrl: 'https://example.com'
    }, {
      headers: { Authorization: `Bearer ${token}` }
    });
    console.log('✓ Link post created:', postRes3.data.post._id);

    // Step 6: List posts
    console.log('\n6. Listing all posts...');
    const listRes = await axios.get(`${BASE_URL}/posts`);
    console.log(`✓ Found ${listRes.data.posts.length} posts`);

    // Step 7: List posts in community
    console.log('\n7. Listing posts in community...');
    const listRes2 = await axios.get(`${BASE_URL}/posts?community=${communityName}`);
    console.log(`✓ Found ${listRes2.data.posts.length} posts in community`);

    console.log('\n✅ All tests passed!');
    process.exit(0);
  } catch (error) {
    console.error('❌ Test failed:');
    if (error.response) {
      console.error('Status:', error.response.status);
      console.error('Data:', JSON.stringify(error.response.data, null, 2));
    } else {
      console.error(error.message);
    }
    process.exit(1);
  }
}

test();
