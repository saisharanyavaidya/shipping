FROM maven as build

WORKDIR /opt/shipping

COPY pom.xml /opt/shipping/
RUN mvn dependency:resolve
COPY src /opt/shipping/src/
RUN mvn package
#We can run container directly here as below but if we do so the image size will be more it is around 631MB as it takes all the src and target folder content into image but to run a container we just need jar file
# We do not need whole code, so we add "FROM maven as build" in line 1 and use the jar alone in container
#CMD [ "java", "-Xmn256m", "-Xmx768m", "-jar", "target/shipping-*.jar" ]

# this is JRE based on alpine OS
FROM openjdk:8-jre-alpine3.9
EXPOSE 8080

WORKDIR /opt/shipping

ENV CART_ENDPOINT=cart:8080
ENV DB_HOST=mysql

#this means copy shipping.jar generated from maven code above and copy it as shipping.jar and run that jar alone
#this represents multi stage build
COPY --from=build /opt/shipping/target/shipping-1.0.jar shipping.jar

CMD [ "java", "-Xmn256m", "-Xmx768m", "-jar", "shipping.jar" ]