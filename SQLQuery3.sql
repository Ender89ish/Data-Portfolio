	 Create view PopulagtionVaccinated as
Select dea.continent, dea.location, convert(DATE,dea.date) as date, dea.[Column 62] as population, vac.new_vaccinations,
SUM(convert(float,vac.new_vaccinations)) over (partition by dea.location order by dea.location, convert(DATE,dea.date)) as Population_Vaxed
From [Portfolio Project]..CovidDeaths dea
Join [Portfolio Project]..CovidVaccinations vac
	 On dea.location = vac.location
	 and dea.date = vac.date
	 Where dea.location noT IN('International','Oceania', 'Asia', 'European Union', 'Europe', 'High income', 'Upper middle income', 'Lower middle income', 'North America', 'World', 'United States', 'South America', 'Africa', 'Low income')
	 and dea.continent is not null
	 Group by dea.date, dea.continent, dea.location, dea.[Column 62], vac.new_vaccinations
	 Order by 2,3,SUM(convert(float,vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date)
	 Offset 0 rows

	 select *
	 from PopulagtionVaccinated