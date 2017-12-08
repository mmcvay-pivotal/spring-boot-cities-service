package io.pivotal.fe.demos;

import static org.junit.Assert.assertNotNull;
import static org.junit.Assert.assertTrue;

import java.util.LinkedHashMap;

import org.junit.Before;
import org.junit.Test;
import org.junit.runner.RunWith;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.boot.test.context.SpringBootTest.WebEnvironment;
import org.springframework.boot.test.web.client.TestRestTemplate;
import org.springframework.http.ResponseEntity;
import org.springframework.test.context.junit4.SpringJUnit4ClassRunner;

/**
 * Test inspired by:
 * http://www.jayway.com/2014/07/04/integration-testing-a-spring-boot-
 * application/
 * https://docs.spring.io/spring-boot/docs/current/reference/html/boot-features-
 * testing.html
 * 
 * @author skazi
 */
@RunWith(SpringJUnit4ClassRunner.class)
@SpringBootTest(webEnvironment=WebEnvironment.RANDOM_PORT)
public class TestRestAPICityRepository {
	TestRestTemplate restTemplate = new TestRestTemplate();

	@Value("${local.server.port}")
	int port;

	private String url;
	
	@Before
	public void setup() {
		url = "http://localhost:" + port + "/cities";
	}
	
	@Test
	public void canFetchCities() {
		Object apiResponse = restTemplate.getForEntity(url,Object.class);
		assertNotNull(apiResponse);
	}
	
	@Test
	public void canFetchCitiesPaged() {
		Object apiResponse = restTemplate.getForEntity(url + "?page=0&size=2",Object.class);
		assertNotNull(apiResponse);
	}

	@SuppressWarnings("unchecked")
	@Test
	public void canFetchBirmingham() {
		ResponseEntity<Object> apiResponse = restTemplate.getForEntity(url + "/search/name?q=Birmingham",Object.class);
		assertNotNull(apiResponse);
		assertNotNull(apiResponse.getBody());
		assertTrue(getTotalElements((LinkedHashMap<String, Object>) apiResponse.getBody()) == 1);
		
		apiResponse = restTemplate.getForEntity(url + "/search/name?q=Birmingham2",Object.class);
		assertNotNull(apiResponse);
		assertNotNull(apiResponse.getBody());
		assertTrue(getTotalElements((LinkedHashMap<String, Object>) apiResponse.getBody()) == 0);
	}
	
	private int getTotalElements(LinkedHashMap<String, Object> respEntity) {
		@SuppressWarnings("unchecked")
		LinkedHashMap<String, Integer> page = (LinkedHashMap<String, Integer>) respEntity.get("page");
		return page.get("totalElements").intValue();
	}
}
