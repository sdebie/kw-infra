package org.kw;

import io.quarkus.runtime.QuarkusApplication;
import io.quarkus.runtime.ShutdownEvent;
import io.quarkus.runtime.annotations.QuarkusMain;
import jakarta.enterprise.context.ApplicationScoped;
import jakarta.enterprise.event.Observes;
import jakarta.inject.Inject;
import lombok.extern.slf4j.Slf4j;
import org.flywaydb.core.Flyway;

@QuarkusMain
@ApplicationScoped
@Slf4j
public class FlywayMain implements QuarkusApplication
{

	@Inject
	Flyway flyway;

	void onStop(@Observes ShutdownEvent ev)
	{
		log.info("Stopping the kw Flyway Service");
	}

	@Override
	public int run(String... args)
	{
		flyway.info();
		return 0;
	}
}
